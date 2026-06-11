import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class PackageQuotationAdmin extends StatefulWidget {
  const PackageQuotationAdmin({super.key});

  @override
  State<PackageQuotationAdmin> createState() => _PackageQuotationAdminState();
}

class _PackageQuotationAdminState extends State<PackageQuotationAdmin> {
  // Current active data category filter tab tracker
  String activeFilter = "All";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // Master Quotation Dataset Records Sources List
  final List<Map<String, dynamic>> quotationsData = [
    {
      "id": "#QT-2024-089",
      "initials": "TH",
      "client": "TechHive Solutions",
      "rep": "Sarah Jenkins",
      "package": "Digital Accelerator",
      "amount": "₹15,500",
      "status": "ACCEPTED",
      "statusBg": Color(0xFFDCFCE7),
      "statusText": Color(0xFF15803D),
      "date": "Oct 12, 2023"
    },
    {
      "id": "#INV-2026-0842",
      "initials": "GM",
      "client": "GA MALL",
      "rep": "Pavithra C",
      "package": "Smart Package",
      "amount": "₹12,000",
      "status": "DRAFT",
      "statusBg": Color(0xFFF1F5F9),
      "statusText": Color(0xFF475569),
      "date": "May 27, 2026"
    },
    {
      "id": "#QT-2024-092",
      "initials": "LM",
      "client": "Lumina Marketing",
      "rep": "Marcus Vance",
      "package": "Global Enterprise",
      "amount": "₹20,500",
      "status": "SENT",
      "statusBg": Color(0xFFE0F2FE),
      "statusText": Color(0xFF0369A1),
      "date": "Oct 14, 2023"
    },
    {
      "id": "#QT-2024-095",
      "initials": "NS",
      "client": "Nova Studios",
      "rep": "Elena Rodriguez",
      "package": "Basic Launch",
      "amount": "₹10,500",
      "status": "DRAFT",
      "statusBg": Color(0xFFF1F5F9),
      "statusText": Color(0xFF475569),
      "date": "Oct 15, 2023"
    },
    {
      "id": "#QT-2024-098",
      "initials": "PJ",
      "client": "Petals & Joy",
      "rep": "David Bloom",
      "package": "Basic Launch",
      "amount": "₹10,500",
      "status": "EXPIRED",
      "statusBg": Color(0xFFFEE2E2),
      "statusText": Color(0xFFB91C1C),
      "date": "Oct 01, 2023"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ── FUNCTIONAL REACTIVE DATA FILTERING ENGINE ──
    List<Map<String, dynamic>> filteredQuotations = quotationsData.where((row) {
      if (!_isFilterMenuOpen || activeFilter == "All") return true;
      return row["status"].toString().toUpperCase() == activeFilter.toUpperCase();
    }).toList();

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

          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available Service Packages",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "View All Packages >",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 1. SERVICE TIER CARDS GRID ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier 1: Kickstart Package
              WidgetCardWrapper(
                child: _buildStandardPackageCard(
                  tier: "TIER 01",
                  title: "Kickstart Package",
                  subtitle: "SMART LAUNCH FOR GROWING BRANDS",
                  price: "₹8,000",
                  period: "/Month",
                  features: [
                    "Platforms: Facebook | Instagram | LinkedIn",
                    "6 Creative Posters",
                    "1 Reels Video / Video Shoot",
                    "Basic Ads Campaign Setup",
                    "AI Monitoring - Smart Layer",
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Tier 2: Smart Package
              WidgetCardWrapper(
                child: _buildPopularPackageCard(
                  tier: "TIER 02",
                  title: "Smart Package",
                  subtitle: "AI OPTIMIZED SOCIAL + CAMPAIGN GROWTH",
                  price: "₹12,000",
                  period: "/setup",
                  features: [
                    "Platforms: Facebook | Instagram | LinkedIn",
                    "12 Premium Posters",
                    "2 Reel Video/ Video Shoot",
                    "Social Media Maintenance",
                    "Ad Campaign Management",
                    "100% AI Monitoring System",
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Tier 3: Performance Package
              WidgetCardWrapper(
                child: _buildStandardPackageCard(
                  tier: "TIER 03",
                  title: "Performance Package",
                  subtitle: "CONVERSION-FOCUSED GOOGLE ADS SYSTEM",
                  price: "₹15,000",
                  period: "/Month",
                  features: [
                    "High-Converting Landing Page",
                    "1000+ Words Optimized Content",
                    "Google Micro Conversion Setup",
                    "Performance Max Campaign",
                    "Full Funnel Monitoring",
                    "100% AI Monitoring System",
                  ],
                  isGoogle: true,
                ),
              ),
            ],
          ),

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
                      Expanded(flex: 3, child: Text("PACKAGE TYPE", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("AMOUNT", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("STATUS", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("DATE", style: _tableHeaderStyle)),
                      Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text("", style: _tableHeaderStyle))),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Dynamic Filtering Rows Mapping Grid View Port Container
                filteredQuotations.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text("No proposals found in this group category.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                        ),
                      )
                    : Column(
                        children: filteredQuotations.map((row) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQuotationRow(
                                row["id"],
                                row["initials"],
                                row["client"],
                                row["rep"],
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
                      Text("Showing 1 to ${filteredQuotations.length} of ${filteredQuotations.length} quotations", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Row(
                        children: [
                          _buildPageButton("<", false),
                          _buildPageButton("1", true),
                          _buildPageButton("2", false),
                          _buildPageButton("3", false),
                          _buildPageButton(">", false),
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

  // ── CARD COMPONENTS CONSTRUCTORS ──

  Widget _buildStandardPackageCard({
    required String tier,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required List<String> features,
    bool isGoogle = false,
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
            child: Column(
              children: features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF22C55E)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF475569)))),
                  ],
                ),
              )).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
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
                child: Column(
                  children: features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)))),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
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

  Widget _buildQuotationRow(String id, String initials, String client, String rep, String type, String amount, String status, Color statusBg, Color statusText, String date) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(rep, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text(type, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Expanded(flex: 3, child: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
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

  Widget _buildPageButton(String text, bool isActive) {
    return Container(
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.white : const Color(0xFF475569)),
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