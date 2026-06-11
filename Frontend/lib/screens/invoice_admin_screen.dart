import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class InvoiceAdminScreen extends StatefulWidget {
  const InvoiceAdminScreen({super.key});

  @override
  State<InvoiceAdminScreen> createState() => _InvoiceAdminScreenState();
}

class _InvoiceAdminScreenState extends State<InvoiceAdminScreen> {
  // Current active data category filter tab tracker
  String activeFilter = "All Logs";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // Master Ledger Dataset Records Sources List
  final List<Map<String, dynamic>> invoiceLedger = [
    {
      "id": "#INV-2026-0842",
      "client": "GA MALL",
      "package": "Smart Package",
      "amount": "₹12,000.00",
      "status": "PARTIAL",
      "statusBg": Color(0xFFFEF3C7),
      "statusText": Color(0xFFD97706),
      "date": "06/15/2026"
    },
    {
      "id": "#INV-2026-0839",
      "client": "JYOTHI",
      "package": "Kickstart Package",
      "amount": "₹8,000.00",
      "status": "PAID",
      "statusBg": Color(0xFFDCFCE7),
      "statusText": Color(0xFF16A34A),
      "date": "06/01/2026"
    },
    {
      "id": "#INV-2026-0812",
      "client": "BRAHMOS",
      "package": "Performance Package",
      "amount": "₹15,000.00",
      "status": "PAID",
      "statusBg": Color(0xFFDCFCE7),
      "statusText": Color(0xFF16A34A),
      "date": "05/24/2026"
    },
    {
      "id": "#INV-2026-0794",
      "client": "KALPAKA",
      "package": "Smart Package",
      "amount": "₹12,000.00",
      "status": "OVERDUE",
      "statusBg": Color(0xFFFEE2E2),
      "statusText": Color(0xFFDC2626),
      "date": "05/10/2026"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ── FUNCTIONAL REACTIVE DATA FILTERING ENGINE ──
    List<Map<String, dynamic>> filteredInvoices = invoiceLedger.where((row) {
      if (!_isFilterMenuOpen || activeFilter == "All Logs") return true;
      if (activeFilter == "Partial") return row["status"] == "PARTIAL";
      return row["status"].toString().toUpperCase() == activeFilter.toUpperCase();
    }).toList();

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
                onPressed: () {
                  Navigator.pushNamed(context, '/add-invoice');
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
              _buildMetricCard("Total Invoiced", "₹4,82,000.00", Icons.receipt_long_rounded, const Color(0xFF2563EB)),
              const SizedBox(width: 16),
              _buildMetricCard("Collected Amount", "₹3,12,000.00", Icons.check_circle_outline_rounded, const Color(0xFF16A34A)),
              const SizedBox(width: 16),
              _buildMetricCard("Outstanding Balance", "₹1,70,000.00", Icons.error_outline_rounded, const Color(0xFFEA580C)),
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
                                  activeFilter = "All Logs"; // Resets clean layout mapping when hidden
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
                      Expanded(flex: 4, child: Text("PACKAGE TYPE", style: _tableHeadingStyle)),
                      Expanded(flex: 3, child: Text("TOTAL AMOUNT", style: _tableHeadingStyle)),
                      Expanded(flex: 3, child: Text("STATUS", style: _tableHeadingStyle)),
                      Expanded(flex: 3, child: Text("DUE DATE", style: _tableHeadingStyle)),
                      Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text("", style: _tableHeadingStyle))),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Dynamic Filtering Rows Mapping Grid View Port Container
                filteredInvoices.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text("No invoice records match this filter status category.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                        ),
                      )
                    : Column(
                        children: filteredInvoices.map((row) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildInvoiceHistoryRow(
                                row["id"],
                                row["client"],
                                row["package"],
                                row["amount"],
                                row["status"],
                                row["statusBg"],
                                row["statusText"],
                                row["date"],
                              ),
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
                      Text("Showing 1 to ${filteredInvoices.length} of ${filteredInvoices.length} ledger files", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Row(
                        children: [
                          _buildPageControlKey("<", false),
                          _buildPageControlKey("1", true),
                          _buildPageControlKey("2", false),
                          _buildPageControlKey("3", false),
                          _buildPageControlKey(">", false),
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

  Widget _buildInvoiceHistoryRow(String id, String client, String package, String amount, String status, Color statusBg, Color statusText, String date) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0052CC)))),
          Expanded(flex: 4, child: Text(client, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
          Expanded(flex: 4, child: Text(package, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Expanded(flex: 3, child: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusText)),
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(date, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF94A3B8)), onPressed: () {}),
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

  Widget _buildPageControlKey(String text, bool isActive) {
    return Container(
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.white : const Color(0xFF475569)),
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