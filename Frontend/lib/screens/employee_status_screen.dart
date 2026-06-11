import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class EmployeeStatusScreen extends StatefulWidget {
  const EmployeeStatusScreen({super.key});

  @override
  State<EmployeeStatusScreen> createState() => _EmployeeStatusScreenState();
}

class _EmployeeStatusScreenState extends State<EmployeeStatusScreen> {
  // Active selected filter category tracker variable
  String activeFilter = "All";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // Master Data Source Ledger matching the exact row specifications from your image layout
  final List<Map<String, dynamic>> masterEmployeeData = [
    {
      "client": "GA MALL",
      "initials": "PC",
      "name": "Pavithra C",
      "task": "Website",
      "duration": "1week",
      "priority": "HIGH",
      "priorityBg": Color(0xFFFFE4E6),
      "priorityText": Color(0xFFEF4444),
      "date": "27 May 2026",
      "timeLeft": "2 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "ON HOLD",
      "statusBg": Color(0xFFF1F5F9),
      "statusText": Color(0xFF64748B)
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "priority": "MEDIUM",
      "priorityBg": Color(0xFFFEF3C7),
      "priorityText": Color(0xFFD97706),
      "date": "30 May 2026",
      "timeLeft": "5 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "IN PROGRESS",
      "statusBg": Color(0xFFE0F2FE),
      "statusText": Color(0xFF0369A1)
    },
    {
      "client": "BRAHMOS",
      "initials": "AD",
      "name": "Arun",
      "task": "Meta Ads",
      "duration": "1 Month",
      "priority": "URGENT",
      "priorityBg": Color(0xFFFEE2E2),
      "priorityText": Color(0xFFDC2626),
      "date": "27 May 2026",
      "timeLeft": "2 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "REVIEW",
      "statusBg": Color(0xFFF3E8FF),
      "statusText": Color(0xFF9333EA)
    },
    {
      "client": "BRAHMOS",
      "initials": "AD",
      "name": "Arun",
      "task": "Meta Ads",
      "duration": "1 Month",
      "priority": "URGENT",
      "priorityBg": Color(0xFFFEE2E2),
      "priorityText": Color(0xFFDC2626),
      "date": "27 May 2026",
      "timeLeft": "2 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "REVIEW",
      "statusBg": Color(0xFFF3E8FF),
      "statusText": Color(0xFF9333EA)
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "priority": "MEDIUM",
      "priorityBg": Color(0xFFFEF3C7),
      "priorityText": Color(0xFFD97706),
      "date": "30 May 2026",
      "timeLeft": "5 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "IN PROGRESS",
      "statusBg": Color(0xFFE0F2FE),
      "statusText": Color(0xFF0369A1)
    },
    {
      "client": "GA MALL",
      "initials": "PC",
      "name": "Pavithra C",
      "task": "Website",
      "duration": "1week",
      "priority": "HIGH",
      "priorityBg": Color(0xFFFFE4E6),
      "priorityText": Color(0xFFEF4444),
      "date": "27 May 2026",
      "timeLeft": "2 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "ON HOLD",
      "statusBg": Color(0xFFF1F5F9),
      "statusText": Color(0xFF64748B)
    },
    {
      "client": "BRAHMOS",
      "initials": "AD",
      "name": "Arun",
      "task": "Meta Ads",
      "duration": "1 Month",
      "priority": "URGENT",
      "priorityBg": Color(0xFFFEE2E2),
      "priorityText": Color(0xFFDC2626),
      "date": "27 May 2026",
      "timeLeft": "2 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "REVIEW",
      "statusBg": Color(0xFFF3E8FF),
      "statusText": Color(0xFF9333EA)
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "priority": "MEDIUM",
      "priorityBg": Color(0xFFFEF3C7),
      "priorityText": Color(0xFFD97706),
      "date": "30 May 2026",
      "timeLeft": "5 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "IN PROGRESS",
      "statusBg": Color(0xFFE0F2FE),
      "statusText": Color(0xFF0369A1)
    },
    {
      "client": "GA MALL",
      "initials": "PC",
      "name": "Pavithra C",
      "task": "Website",
      "duration": "1week",
      "priority": "HIGH",
      "priorityBg": Color(0xFFFFE4E6),
      "priorityText": Color(0xFFEF4444),
      "date": "27 May 2026",
      "timeLeft": "2 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "ON HOLD",
      "statusBg": Color(0xFFF1F5F9),
      "statusText": Color(0xFF64748B)
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "priority": "MEDIUM",
      "priorityBg": Color(0xFFFEF3C7),
      "priorityText": Color(0xFFD97706),
      "date": "30 May 2026",
      "timeLeft": "5 Days Left",
      "timeColor": Color(0xFF22C55E),
      "status": "IN PROGRESS",
      "statusBg": Color(0xFFE0F2FE),
      "statusText": Color(0xFF0369A1)
    }
  ];

  @override
  Widget build(BuildContext context) {
    // ── FUNCTIONAL REACTIVE DATA FILTERING ENGINE ──
    List<Map<String, dynamic>> filteredRows = masterEmployeeData.where((row) {
      if (!_isFilterMenuOpen || activeFilter == "All") return true;
      return row["status"].toString().toUpperCase() == activeFilter.toUpperCase();
    }).toList();

    return AdminLayout(
      pageTitle: "Employee Status",
      currentRoute: "/employee-status",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title & Global Creation Toolbar Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Employee Status",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Assign, monitor, and manage employee tasks based on departments, projects, and client deliverables.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              // ElevatedButton.icon(
              //   onPressed: () {},
              //   icon: const Icon(Icons.add, size: 16, color: Colors.white),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF0052CC),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              //     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              //     elevation: 0,
              //   ),
              //   label: const Text("Create Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              // ),
            ],
          ),

          const SizedBox(height: 28),

          // ── MAIN CONTENT LEDGER DATA CONTAINER TABLE ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dynamic Interactive Ribbon Filter Tabs Panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Employee Status",
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
                                _buildFilterTab("Pending"),
                                _buildFilterTab("In Progress"),
                                _buildFilterTab("Review"),
                                _buildFilterTab("Completed"),
                                _buildFilterTab("Overdue"),
                                _buildFilterTab("On Hold"),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          
                          // ── MASTER FILTERS SHUTTER TOGGLE BUTTON ──
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isFilterMenuOpen = !_isFilterMenuOpen;
                                if (!_isFilterMenuOpen) {
                                  activeFilter = "All"; // Resets filter configuration when drawer rolls up
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

                // 2. Fixed Data Table Heading Headers Ribbon
                Container(
                  color: Colors.white,
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text("CLIENT", style: _headerStyle)),
                      Expanded(flex: 3, child: Text("EMPLOYEE NAME", style: _headerStyle)),
                      Expanded(flex: 2, child: Text("TASKS", style: _headerStyle)),
                      Expanded(flex: 2, child: Text("TIME/DURATION", style: _headerStyle)),
                      Expanded(flex: 2, child: Text("PRIORITY", style: _headerStyle)),
                      Expanded(flex: 3, child: Text("DUE DATE", style: _headerStyle)),
                      Expanded(flex: 2, child: Text("STATUS", style: _headerStyle)),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                // 3. Vertically Scrollable Filtered Grid Rows Area
                Container(
                  height: 480, 
                  child: filteredRows.isEmpty
                      ? const Center(
                          child: Text(
                            "No employee task matches this status group.",
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredRows.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final row = filteredRows[index];
                            return Container(
                              height: 64,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      row["client"],
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: const BoxDecoration(color: Color(0xFFDCE4F7), shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text(
                                            row["initials"],
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4A69B3)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          row["name"],
                                          style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(row["task"], style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(row["duration"], style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(color: row["priorityBg"], borderRadius: BorderRadius.circular(4)),
                                        child: Text(
                                          row["priority"],
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: row["priorityText"], letterSpacing: 0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(row["date"], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 3),
                                        Text(row["timeLeft"], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: row["timeColor"])),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(color: row["statusBg"], borderRadius: BorderRadius.circular(4)),
                                        child: Text(
                                          row["status"],
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: row["statusText"], letterSpacing: 0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // 4. Data Ledger Pagination Footer Component
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Showing 1 to ${filteredRows.length} of ${filteredRows.length} items", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── CORE UTILITY DESIGN BUTTON GENERATORS ──
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
      width: 26, height: 26,
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

  static const TextStyle _headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.8);
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