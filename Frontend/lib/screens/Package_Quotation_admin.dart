import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../layouts/admin_layout.dart';

class PackageQuotationAdmin extends StatefulWidget {
  const PackageQuotationAdmin({super.key});

  @override
  State<PackageQuotationAdmin> createState() => _PackageQuotationAdminState();
}

class _PackageQuotationAdminState extends State<PackageQuotationAdmin> {
  // ── API base URL ──────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://localhost:3000/api';

  // ── PACKAGE VIEW TOGGLE: show only first 3, or all ──
  bool _showAllPackages = false;

  // ── Service Packages — now loaded from backend ────────────────────────────────
  // Each package: { id, title, subtitle, price, period, features: List<String>, is_google, is_popular }
  List<Map<String, dynamic>> packagesData = [];
  bool _loadingPackages = true;
  String? _packagesError;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _fetchQuotations();
  }

  // ── FETCH all packages ────────────────────────────────────────────────────────
  Future<void> _fetchPackages() async {
    setState(() { _loadingPackages = true; _packagesError = null; });
    try {
      final response = await http.get(Uri.parse('$_baseUrl/packages'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          packagesData = List<Map<String, dynamic>>.from(body['data']);
          _loadingPackages = false;
        });
      } else {
        setState(() { _packagesError = 'Server returned ${response.statusCode}'; _loadingPackages = false; });
      }
    } catch (e) {
      setState(() { _packagesError = 'Cannot connect to server'; _loadingPackages = false; });
    }
  }

  // ── CREATE package — returns null on success, error message on failure ────────
  Future<String?> _createPackage(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/packages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        await _fetchPackages();
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['message'] ?? 'Failed to create package';
      }
    } catch (e) {
      return 'Cannot connect to server';
    }
  }

  // ── UPDATE package ───────────────────────────────────────────────────────────
  Future<String?> _updatePackage(int id, Map<String, dynamic> payload) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/packages/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        await _fetchPackages();
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['message'] ?? 'Failed to update package';
      }
    } catch (e) {
      return 'Cannot connect to server';
    }
  }

  // ── DELETE package ───────────────────────────────────────────────────────────
  Future<void> _deletePackage(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/packages/$id'));
      if (response.statusCode == 200) {
        await _fetchPackages();
        if (packagesData.length <= 3) _showAllPackages = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Package deleted'),
          backgroundColor: Color(0xFFDC2626),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to delete package'),
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

  // Current active data category filter tab tracker
  String activeFilter = "All";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // ── Recent Quotations — now loaded from backend ───────────────────────────────
  List<Map<String, dynamic>> quotationsData = [];
  bool _loadingQuotations = true;
  String? _quotationsError;

  // ── Pagination for the Recent Quotations table ────────────────────────────────
  static const int _quotationsPerPage = 6;
  int _currentPage = 1;

  // ── FETCH all quotations ──────────────────────────────────────────────────────
  Future<void> _fetchQuotations() async {
    setState(() { _loadingQuotations = true; _quotationsError = null; });
    try {
      final response = await http.get(Uri.parse('$_baseUrl/quotations'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          quotationsData = List<Map<String, dynamic>>.from(body['data']);
          _loadingQuotations = false;
        });
      } else {
        setState(() { _quotationsError = 'Server returned ${response.statusCode}'; _loadingQuotations = false; });
      }
    } catch (e) {
      setState(() { _quotationsError = 'Cannot connect to server'; _loadingQuotations = false; });
    }
  }

  // ── UPDATE quotation status ──────────────────────────────────────────────────
  Future<void> _updateQuotationStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/quotations/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode == 200) {
        await _fetchQuotations();
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

  // ── DELETE quotation ──────────────────────────────────────────────────────────
  Future<void> _deleteQuotation(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/quotations/$id'));
      if (response.statusCode == 200) {
        await _fetchQuotations();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Quotation deleted'),
          backgroundColor: Color(0xFFDC2626),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to delete quotation'),
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

  // ── Status badge colors ───────────────────────────────────────────────────────
  static const Map<String, Color> _statusBg = {
    'DRAFT':    Color(0xFFF1F5F9),
    'SENT':     Color(0xFFE0F2FE),
    'ACCEPTED': Color(0xFFDCFCE7),
    'EXPIRED':  Color(0xFFFEE2E2),
  };
  static const Map<String, Color> _statusText = {
    'DRAFT':    Color(0xFF475569),
    'SENT':     Color(0xFF0369A1),
    'ACCEPTED': Color(0xFF15803D),
    'EXPIRED':  Color(0xFFB91C1C),
  };

  @override
  Widget build(BuildContext context) {
    // ── FUNCTIONAL REACTIVE DATA FILTERING ENGINE ──
    List<Map<String, dynamic>> filteredQuotations = quotationsData.where((row) {
      if (!_isFilterMenuOpen || activeFilter == "All") return true;
      return row["status"].toString().toUpperCase() == activeFilter.toUpperCase();
    }).toList();

    // ── PAGINATION — show only _quotationsPerPage rows at a time ──────────────
    final totalQuotations = filteredQuotations.length;
    final totalPages = totalQuotations == 0 ? 1 : (totalQuotations / _quotationsPerPage).ceil();
    // Clamp current page in case the filtered list shrank (e.g. status change/delete)
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;

    final startIndex = (_currentPage - 1) * _quotationsPerPage;
    final endIndex = (startIndex + _quotationsPerPage > totalQuotations)
        ? totalQuotations
        : startIndex + _quotationsPerPage;
    final pagedQuotations = filteredQuotations.sublist(
      startIndex < totalQuotations ? startIndex : 0,
      endIndex,
    );

    // ── PACKAGES TO DISPLAY: first 3, or all if expanded ──
    final visiblePackages = _showAllPackages
        ? packagesData
        : packagesData.take(3).toList();
    final hasMorePackages = packagesData.length > 3;

    return AdminLayout(
      pageTitle: "Package & Quotation",
      currentRoute: "/quotation",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Header Banner Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Package & Quotation",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Manage service tiers and track pending client proposals.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  // ── CREATE NEW PACKAGE BUTTON ──
                  OutlinedButton.icon(
                    onPressed: () => _showPackageFormDialog(context),
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFF0052CC)),
                    label: const Text("Create New Package",
                        style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0052CC)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-quotation');
                    },
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      elevation: 0,
                    ),
                    label: const Text("Create New Quotation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available Service Packages",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              // ── VIEW ALL / SHOW LESS toggle — only shown if more than 3 packages exist ──
              if (hasMorePackages)
                GestureDetector(
                  onTap: () => setState(() => _showAllPackages = !_showAllPackages),
                  child: Text(
                    _showAllPackages ? "Show Less <" : "View All Packages (${packagesData.length}) >",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 1. SERVICE TIER CARDS GRID ──
          if (_loadingPackages)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF0052CC))),
            )
          else if (_packagesError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Column(children: [
                Text(_packagesError!, style: const TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchPackages,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052CC)),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ])),
            )
          else if (packagesData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No packages yet. Click "Create New Package" to add one.',
                  style: TextStyle(color: Color(0xFF94A3B8)))),
            )
          else
            LayoutBuilder(builder: (context, constraints) {
              // ── Card width: same as a 3-up Expanded layout (3 equal columns, 2 gaps of 18) ──
              final cardWidth = (constraints.maxWidth - 18 * 2) / 3;

              Widget buildCard(int globalIndex) {
                final pkg = packagesData[globalIndex];
                final tierLabel = "TIER ${(globalIndex + 1).toString().padLeft(2, '0')}";
                return (pkg["is_popular"] == true)
                    ? _buildPopularPackageCard(
                        tier: tierLabel,
                        title: pkg["title"],
                        subtitle: pkg["subtitle"],
                        price: pkg["price"],
                        period: pkg["period"],
                        features: List<String>.from(pkg["features"]),
                        onEdit: () => _showPackageFormDialog(context, editIndex: globalIndex),
                      )
                    : _buildStandardPackageCard(
                        tier: tierLabel,
                        title: pkg["title"],
                        subtitle: pkg["subtitle"],
                        price: pkg["price"],
                        period: pkg["period"],
                        features: List<String>.from(pkg["features"]),
                        isGoogle: pkg["is_google"] == true,
                        onEdit: () => _showPackageFormDialog(context, editIndex: globalIndex),
                      );
              }

              // ── Collapsed view (≤3 packages, or "View All" not expanded): ──
              // original equal-width 3-column Row using Expanded
              if (!_showAllPackages || packagesData.length <= 3) {
                final cards = <Widget>[];
                for (int j = 0; j < visiblePackages.length; j++) {
                  cards.add(WidgetCardWrapper(child: buildCard(j)));
                  if (j < visiblePackages.length - 1) cards.add(const SizedBox(width: 18));
                }
                // Pad incomplete rows so Expanded ratios stay consistent
                while (cards.length < 5) {
                  cards.add(const SizedBox(width: 18));
                  cards.add(const Expanded(child: SizedBox()));
                }
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards);
              }

              // ── Expanded view with >3 packages: horizontal scroll, fixed card width ──
              // Mirrors the reference design — 3 full cards visible with the next
              // card's edge peeking in, scrollable left-to-right.
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 16), // ✅ room for "Most Popular" badge (top: -12)
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(packagesData.length, (j) {
                    return Padding(
                      padding: EdgeInsets.only(right: j < packagesData.length - 1 ? 18 : 0),
                      child: SizedBox(width: cardWidth, child: buildCard(j)),
                    );
                  }),
                ),
              );
            }),

          const SizedBox(height: 40),

          // ── 2. RECENT QUOTATIONS CONTAINER GRID TABLE ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Control Top Ribbon Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Quotations",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      Row(
                        children: [
                          // ── ANIMATED FILTER CHIPS MENU BLOCK ──
                          AnimatedVisibility(
                            visible: _isFilterMenuOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFilterTab("All"),
                                _buildFilterTab("Draft"),
                                _buildFilterTab("Sent"),
                                _buildFilterTab("Accepted"),
                                _buildFilterTab("Expired"),
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
                                  activeFilter = "All"; // Clean filter reset when drawer closed
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
                                    _isFilterMenuOpen ? "Hide Filters" : "Filters",
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

                // Main Table Columns Title Index Ribbon
                Container(
                  color: const Color(0xFFF8FAFC),
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: Text("QUOTATION ID", style: _tableHeaderStyle)),
                      Expanded(flex: 4, child: Text("CLIENT NAME", style: _tableHeaderStyle)),
                      Expanded(flex: 2, child: Text("PACKAGE TYPE", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("AMOUNT", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("STATUS", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("DATE", style: _tableHeaderStyle)),
                      Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text("ACTIONS", style: _tableHeaderStyle))),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Dynamic Filtering Rows Mapping Grid View Port Container
                if (_loadingQuotations)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF0052CC))),
                  )
                else if (_quotationsError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Column(children: [
                      Text(_quotationsError!, style: const TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchQuotations,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052CC)),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ])),
                  )
                else if (filteredQuotations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("No proposals found in this group category.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ),
                  )
                else
                  Column(
                    children: pagedQuotations.map((row) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuotationRow(row),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                        ],
                      );
                    }).toList(),
                  ),

                // Pagination Footer Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalQuotations == 0
                            ? "Showing 0 of 0 quotations"
                            : "Showing ${startIndex + 1} to $endIndex of $totalQuotations quotations",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Row(
                        children: [
                          _buildPageButton("<", false, onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null),
                          for (int p = 1; p <= totalPages; p++)
                            _buildPageButton("$p", p == _currentPage, onTap: () => setState(() => _currentPage = p)),
                          _buildPageButton(">", false, onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── CREATE / EDIT PACKAGE DIALOG ────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════
  void _showPackageFormDialog(BuildContext context, {int? editIndex}) {
    final isEdit = editIndex != null;
    final existing = isEdit ? packagesData[editIndex] : null;

    final titleCtrl    = TextEditingController(text: existing?["title"] ?? "");
    final subtitleCtrl = TextEditingController(text: existing?["subtitle"] ?? "");
    final priceCtrl    = TextEditingController(text: existing?["price"] ?? "");
    final periodCtrl   = TextEditingController(text: existing?["period"] ?? "/Month");

    bool isGoogle  = existing?["is_google"] == true;
    bool isPopular = existing?["is_popular"] == true;

    // Feature rows — each is its own TextEditingController for editing
    final List<TextEditingController> featureCtrls = existing != null
        ? List<String>.from(existing["features"])
            .map((f) => TextEditingController(text: f))
            .toList()
        : [TextEditingController()]; // start with one empty feature row

    String? dialogError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {

          void addFeatureRow() {
            setDialogState(() => featureCtrls.add(TextEditingController()));
          }

          void removeFeatureRow(int idx) {
            setDialogState(() => featureCtrls.removeAt(idx));
          }

          Future<void> handleSubmit() async {
            final title    = titleCtrl.text.trim();
            final subtitle = subtitleCtrl.text.trim();
            final price    = priceCtrl.text.trim();
            final period   = periodCtrl.text.trim();
            final features = featureCtrls
                .map((c) => c.text.trim())
                .where((f) => f.isNotEmpty)
                .toList();

            if (title.isEmpty || price.isEmpty || features.isEmpty) {
              setDialogState(() => dialogError = 'Please fill Package Title, Price, and at least one feature');
              return;
            }

            setDialogState(() { isSubmitting = true; dialogError = null; });

            final payload = {
              "title": title,
              "subtitle": subtitle,
              "price": price,
              "period": period.isEmpty ? "/Month" : period,
              "isGoogle": isGoogle,
              "isPopular": isPopular,
              "features": features,
            };

            final error = isEdit
                ? await _updatePackage(existing!["id"], payload)
                : await _createPackage(payload);

            if (error == null) {
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                content: Text(isEdit ? 'Package updated' : 'Package created'),
                backgroundColor: const Color(0xFF16A34A),
              ));
            } else {
              setDialogState(() { isSubmitting = false; dialogError = error; });
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 640),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? "Edit Package" : "Create New Package",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),

                  // ── ERROR BANNER ──
                  if (dialogError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(dialogError!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Scrollable form body ──
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dialogField(label: "Package Title *", hint: "e.g. Kickstart Package", controller: titleCtrl),
                          const SizedBox(height: 14),
                          _dialogField(label: "Subtitle", hint: "e.g. SMART LAUNCH FOR GROWING BRANDS", controller: subtitleCtrl),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(child: _dialogField(label: "Price *", hint: "e.g. ₹8,000", controller: priceCtrl)),
                            const SizedBox(width: 14),
                            Expanded(child: _dialogField(label: "Period", hint: "e.g. /Month", controller: periodCtrl)),
                          ]),
                          const SizedBox(height: 16),

                          // ── Toggles ──
                          Row(children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: isGoogle,
                                onChanged: (v) => setDialogState(() => isGoogle = v ?? false),
                                title: const Text("Google Ads Package",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                subtitle: const Text("Shows '(Ad Wallet & Domain Excluded)'",
                                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                activeColor: const Color(0xFF0052CC),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: isPopular,
                                onChanged: (v) => setDialogState(() => isPopular = v ?? false),
                                title: const Text("Mark as 'Most Popular'",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                subtitle: const Text("Highlights card in blue",
                                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                activeColor: const Color(0xFF0052CC),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),

                          // ── Features list ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Package Features *",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                              TextButton.icon(
                                onPressed: addFeatureRow,
                                icon: const Icon(Icons.add, size: 16, color: Color(0xFF0052CC)),
                                label: const Text("Add Feature",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0052CC))),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...featureCtrls.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final ctrl = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF22C55E)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: TextField(
                                      controller: ctrl,
                                      decoration: InputDecoration(
                                        hintText: "Feature description",
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                  onPressed: featureCtrls.length > 1 ? () => removeFeatureRow(idx) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ]),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ── DELETE PACKAGE button — only shown when editing ──────────
                      if (isEdit) ...[
                        OutlinedButton.icon(
                          onPressed: isSubmitting ? null : () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Package'),
                                content: Text('Remove "${existing!["title"]}"? This cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context), // close confirm dialog only
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // close confirm dialog
                                      Navigator.pop(context); // close edit dialog
                                      _deletePackage(existing["id"]); // ✅ DELETE /api/packages/:id
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                          label: const Text("Delete Package",
                              style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                        const Spacer(),
                      ],
                      OutlinedButton(
                        onPressed: isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052CC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEdit ? "Save Changes" : "Create Package",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dialogField({required String label, required String hint, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
            ),
          ),
        ),
      ],
    );
  }

  // ── CARD COMPONENTS CONSTRUCTORS ──

  Widget _buildStandardPackageCard({
    required String tier,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required List<String> features,
    bool isGoogle = false,
    required VoidCallback onEdit,
  }) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
        boxShadow: const [BoxShadow(color: Color(0xFFF1F5F9), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tier, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              Text(period, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          Text(isGoogle ? "(Ad Wallet & Domain Excluded)" : "(Ad Wallet Excluded)", style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9))),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF22C55E)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF475569)))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Edit Package", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPackageCard({
    required String tier,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onEdit,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 380,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0052CC),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Color(0xFFDBE5F5), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tier, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text(period, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
                ],
              ),
              Text("(Ad Wallet Excluded)", style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.6))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white.withOpacity(0.1))),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)))),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Edit Package", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0052CC))),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4)),
            child: const Text("Most Popular", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  // ── ROW GRID TAB BUILDERS ──

  static const TextStyle _tableHeaderStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5);

  Widget _buildQuotationRow(Map<String, dynamic> row) {
    final int id          = row["id"];
    final String quotNo   = row["quotation_no"] ?? '';
    final String client   = row["client_name"] ?? '';
    final String type     = row["package_type"] ?? '-';
    final double total    = double.tryParse(row["total_amount"]?.toString() ?? '0') ?? 0;
    final String amount   = "₹${total.toStringAsFixed(0)}";
    final String status   = (row["status"] ?? 'DRAFT').toString().toUpperCase();
    final String date     = row["quotation_date"] ?? '';

    // Derive 2-letter initials from the client name
    final words = client.trim().split(RegExp(r'\s+'));
    final initials = (words.isNotEmpty ? words[0].substring(0, 1) : '') +
        (words.length > 1 ? words[1].substring(0, 1) : '');

    final statusBg   = _statusBg[status]   ?? const Color(0xFFF1F5F9);
    final statusText = _statusText[status] ?? const Color(0xFF475569);

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(quotNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: Text(initials.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(client, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),

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
                      if (val != null && val != status) _updateQuotationStatus(id, val);
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
                  // View — opens the quotation in read-only mode
                  Tooltip(
                    message: 'View',
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context, '/create-quotation',
                        arguments: {'quotationId': id, 'viewOnly': true},
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                  ),
                  // Edit — opens the quotation, fully editable
                  Tooltip(
                    message: 'Edit',
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context, '/create-quotation',
                        arguments: {'quotationId': id, 'viewOnly': false},
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0052CC)),
                      ),
                    ),
                  ),
                  // Delete — confirms before removing
                  Tooltip(
                    message: 'Delete',
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Quotation'),
                            content: Text('Remove "$quotNo"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteQuotation(id);
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

  Widget _buildPageButton(String text, bool isActive, {VoidCallback? onTap}) {
    final isDisabled = onTap == null && !isActive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 26,
        height: 26,
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

// ── CUSTOM GRID ROW LAYOUT PROTECTION WRAPPER ──
class WidgetCardWrapper extends StatelessWidget {
  final Widget child;
  const WidgetCardWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: child);
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