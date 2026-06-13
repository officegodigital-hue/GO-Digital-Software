import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../layouts/admin_layout.dart';

class InvoiceAdminScreen extends StatefulWidget {
  const InvoiceAdminScreen({super.key});

  @override
  State<InvoiceAdminScreen> createState() => _InvoiceAdminScreenState();
}

class _InvoiceAdminScreenState extends State<InvoiceAdminScreen> {
  // ── API base URL ──────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://localhost:3000/api';

  // Current active data category filter tab tracker
  String activeFilter = "All Logs";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // ── Invoice Ledger — now loaded from backend ──────────────────────────────────
  List<Map<String, dynamic>> invoiceLedger = [];
  bool _loadingInvoices = true;
  String? _invoicesError;

  // ── Summary metrics — loaded from backend ─────────────────────────────────────
  double _totalInvoiced = 0;
  double _collectedAmount = 0;
  double _outstandingBalance = 0;
  bool _loadingMetrics = true;

  // ── Pagination for the Invoice History table ──────────────────────────────────
  static const int _invoicesPerPage = 6;
  int _currentPage = 1;

  // ── Status badge colors ───────────────────────────────────────────────────────
  static const Map<String, Color> _statusBg = {
    'DRAFT':   Color(0xFFF1F5F9),
    'PARTIAL': Color(0xFFFEF3C7),
    'PAID':    Color(0xFFDCFCE7),
    'OVERDUE': Color(0xFFFEE2E2),
  };
  static const Map<String, Color> _statusText = {
    'DRAFT':   Color(0xFF475569),
    'PARTIAL': Color(0xFFD97706),
    'PAID':    Color(0xFF16A34A),
    'OVERDUE': Color(0xFFDC2626),
  };

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _fetchMetrics();
  }

  // ── FETCH all invoices ────────────────────────────────────────────────────────
  Future<void> _fetchInvoices() async {
    setState(() { _loadingInvoices = true; _invoicesError = null; });
    try {
      final response = await http.get(Uri.parse('$_baseUrl/invoices'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          invoiceLedger = List<Map<String, dynamic>>.from(body['data']);
          _loadingInvoices = false;
        });
      } else {
        setState(() { _invoicesError = 'Server returned ${response.statusCode}'; _loadingInvoices = false; });
      }
    } catch (e) {
      setState(() { _invoicesError = 'Cannot connect to server'; _loadingInvoices = false; });
    }
  }

  // ── FETCH summary metrics for the top cards ──────────────────────────────────
  Future<void> _fetchMetrics() async {
    setState(() => _loadingMetrics = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/invoices/metrics'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        setState(() {
          _totalInvoiced = double.tryParse(data['total_invoiced'].toString()) ?? 0;
          _collectedAmount = double.tryParse(data['collected_amount'].toString()) ?? 0;
          _outstandingBalance = double.tryParse(data['outstanding_balance'].toString()) ?? 0;
          _loadingMetrics = false;
        });
      } else {
        setState(() => _loadingMetrics = false);
      }
    } catch (e) {
      setState(() => _loadingMetrics = false);
    }
  }

  // ── UPDATE invoice status ─────────────────────────────────────────────────────
  Future<void> _updateInvoiceStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/invoices/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode == 200) {
        await _fetchInvoices();
        await _fetchMetrics();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update status'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cannot connect to server'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  // ── DELETE invoice ─────────────────────────────────────────────────────────────
  Future<void> _deleteInvoice(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/invoices/$id'));
      if (response.statusCode == 200) {
        await _fetchInvoices();
        await _fetchMetrics();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invoice deleted'),
          backgroundColor: Color(0xFFDC2626),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to delete invoice'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cannot connect to server'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  String _formatCurrency(double v) {
    // Indian-style grouping: 1,82,000.00
    final isNegative = v < 0;
    v = v.abs();
    final parts = v.toStringAsFixed(2).split('.');
    String intPart = parts[0];
    String result;
    if (intPart.length <= 3) {
      result = intPart;
    } else {
      final last3 = intPart.substring(intPart.length - 3);
      final rest = intPart.substring(0, intPart.length - 3);
      final restWithCommas = rest.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+$)'),
        (m) => '${m[1]},',
      );
      result = '$restWithCommas,$last3';
    }
    return '${isNegative ? '-' : ''}₹$result.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    // ── FUNCTIONAL REACTIVE DATA FILTERING ENGINE ──
    List<Map<String, dynamic>> filteredInvoices = invoiceLedger.where((row) {
      if (!_isFilterMenuOpen || activeFilter == "All Logs") return true;
      final status = (row["status"] ?? '').toString().toUpperCase();
      if (activeFilter == "Partial") return status == "PARTIAL";
      return status == activeFilter.toUpperCase();
    }).toList();

    // ── PAGINATION ──────────────────────────────────────────────────────────────
    final totalInvoices = filteredInvoices.length;
    final totalPages = totalInvoices == 0 ? 1 : (totalInvoices / _invoicesPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;
    final startIndex = (_currentPage - 1) * _invoicesPerPage;
    final endIndex = (startIndex + _invoicesPerPage > totalInvoices) ? totalInvoices : startIndex + _invoicesPerPage;
    final pagedInvoices = filteredInvoices.sublist(
      startIndex < totalInvoices ? startIndex : 0,
      endIndex,
    );

    return AdminLayout(
      pageTitle: "Invoice Management",
      currentRoute: "/invoice",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Action Toolbar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Invoices",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track real-time customer billing statements, distributions, and accounts receivable collections.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/add-invoice');
                  _fetchInvoices();
                  _fetchMetrics();
                },
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  elevation: 0,
                ),
                label: const Text("Add Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Aggregate Metrics Analytics Summary Panel Row ──
          Row(
            children: [
              _buildMetricCard("Total Invoiced", _loadingMetrics ? "—" : _formatCurrency(_totalInvoiced), Icons.receipt_long_rounded, const Color(0xFF2563EB)),
              const SizedBox(width: 16),
              _buildMetricCard("Collected Amount", _loadingMetrics ? "—" : _formatCurrency(_collectedAmount), Icons.check_circle_outline_rounded, const Color(0xFF16A34A)),
              const SizedBox(width: 16),
              _buildMetricCard("Outstanding Balance", _loadingMetrics ? "—" : _formatCurrency(_outstandingBalance), Icons.error_outline_rounded, const Color(0xFFEA580C)),
            ],
          ),

          const SizedBox(height: 32),

          // ── Historical Invoices Log Records View Grid ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Tab Controller Toolbar Ribbon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Invoice History",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      Row(
                        children: [
                          // ── ANIMATED FILTER CHIPS MENU BLOCK ──
                          AnimatedVisibility(
                            visible: _isFilterMenuOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFilterTab("All Logs"),
                                _buildFilterTab("Paid"),
                                _buildFilterTab("Partial"),
                                _buildFilterTab("Overdue"),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),

                          // ── MASTER FILTERS SHUTTER TOGGLE BUTTON ──
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isFilterMenuOpen = !_isFilterMenuOpen;
                                if (!_isFilterMenuOpen) {
                                  activeFilter = "All Logs";
                                  _currentPage = 1;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isFilterMenuOpen ? const Color(0xFFF1F5F9) : Colors.transparent,
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isFilterMenuOpen ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                                    size: 14,
                                    color: const Color(0xFF475569)
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isFilterMenuOpen ? "Hide Filter" : "Filter",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Datagrid Column Title Headings Index
                Container(
                  color: const Color(0xFFF8FAFC),
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: Text("INVOICE ID", style: _tableHeadingStyle)),
                      Expanded(flex: 4, child: Text("CLIENT NAME", style: _tableHeadingStyle)),
                      Expanded(flex: 2, child: Text("PACKAGE TYPE", style: _tableHeadingStyle)),
                      Expanded(flex: 3, child: Text("TOTAL AMOUNT", style: _tableHeadingStyle)),
                      Expanded(flex: 3, child: Text("STATUS", style: _tableHeadingStyle)),
                      Expanded(flex: 3, child: Text("DUE DATE", style: _tableHeadingStyle)),
                      Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text("ACTIONS", style: _tableHeadingStyle))),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Dynamic Filtering Rows Mapping Grid View Port Container
                if (_loadingInvoices)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF0052CC))),
                  )
                else if (_invoicesError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Column(children: [
                      Text(_invoicesError!, style: const TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchInvoices,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052CC)),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ])),
                  )
                else if (filteredInvoices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("No invoice records match this filter status category.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ),
                  )
                else
                  Column(
                    children: pagedInvoices.map((row) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInvoiceHistoryRow(row),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                        ],
                      );
                    }).toList(),
                  ),

                // Datagrid Pagination Footer Area Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalInvoices == 0
                            ? "Showing 0 of 0 ledger files"
                            : "Showing ${startIndex + 1} to $endIndex of $totalInvoices ledger files",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Row(
                        children: [
                          _buildPageControlKey("<", false, onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null),
                          for (int p = 1; p <= totalPages; p++)
                            _buildPageControlKey("$p", p == _currentPage, onTap: () => setState(() => _currentPage = p)),
                          _buildPageControlKey(">", false, onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── CORE UTILITY DESIGN CARD MODULAR GENERATORS ──
  Widget _buildMetricCard(String title, String rawValue, IconData icon, Color badgeAccent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: badgeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: badgeAccent, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(rawValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            )
          ],
        ),
      ),
    );
  }

  static const TextStyle _tableHeadingStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5);

  Widget _buildInvoiceHistoryRow(Map<String, dynamic> row) {
    final int id          = row["id"];
    final String invNo    = row["invoice_no"] ?? '';
    final String client   = row["client_name"] ?? '';
    final String type     = row["package_type"] ?? '-';
    final double total    = double.tryParse(row["total_amount"]?.toString() ?? '0') ?? 0;
    final String amount   = _formatCurrency(total);
    final String status   = (row["status"] ?? 'DRAFT').toString().toUpperCase();
    final String date     = row["invoice_date"] ?? '';

    final statusBg   = _statusBg[status]   ?? const Color(0xFFF1F5F9);
    final statusText = _statusText[status] ?? const Color(0xFF475569);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(invNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0052CC)))),
          Expanded(flex: 4, child: Text(client, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),

          // ── STATUS DROPDOWN ────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    isDense: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: statusText),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusText),
                    dropdownColor: Colors.white,
                    items: _statusBg.keys.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusText[s])),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null && val != status) _updateInvoiceStatus(id, val);
                    },
                  ),
                ),
              ),
            ),
          ),

          Expanded(flex: 3, child: Text(date, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),

          // ── ACTIONS: inline icon-only View / Edit / Delete buttons ──────────
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'View',
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(
                          context, '/add-invoice',
                          arguments: {'invoiceId': id, 'viewOnly': true},
                        );
                        _fetchInvoices();
                        _fetchMetrics();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Edit',
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(
                          context, '/add-invoice',
                          arguments: {'invoiceId': id, 'viewOnly': false},
                        );
                        _fetchInvoices();
                        _fetchMetrics();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0052CC)),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Delete',
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Invoice'),
                            content: Text('Remove "$invNo"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteInvoice(id);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    bool isActive = activeFilter.toUpperCase() == label.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            activeFilter = label;
            _currentPage = 1;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFF0052CC) : Colors.transparent,
          side: BorderSide(color: isActive ? const Color(0xFF0052CC) : const Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPageControlKey(String text, bool isActive, {VoidCallback? onTap}) {
    final isDisabled = onTap == null && !isActive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0052CC) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isActive ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive
                ? Colors.white
                : (isDisabled ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}

// ── CUSTOM LIGHTWEIGHT ANIMATED VISIBILITY HELPER WIDGET ──
class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedVisibility({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: visible ? child : const SizedBox.shrink(),
    );
  }
}