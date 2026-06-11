import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class ManagerReviewScreen extends StatefulWidget {
  const ManagerReviewScreen({super.key});

  @override
  State<ManagerReviewScreen> createState() => _ManagerReviewScreenState();
}

class _ManagerReviewScreenState extends State<ManagerReviewScreen> {
  // Current active filter category tab tracker
  String activeFilter = "All";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // Master Work Review Logs Dataset
  final List<Map<String, dynamic>> reviewData = [
    {
      "client": "GA MALL",
      "initials": "PC",
      "name": "Pavithra C",
      "task": "Website",
      "duration": "1week",
      "status": "SUBMITTED",
      "action": "ACTION",
      "controller": TextEditingController(text: "")
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "APPROVED",
      "controller": TextEditingController(text: "Great work on content graphics.")
    },
    {
      "client": "BRAHMOS",
      "initials": "AD",
      "name": "Arun",
      "task": "Meta Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "ACTION",
      "controller": TextEditingController(text: "")
    },
    {
      "client": "BRAHMOS",
      "initials": "AD",
      "name": "Arun",
      "task": "Meta Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "ACTION",
      "controller": TextEditingController(text: "")
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "REWORK",
      "controller": TextEditingController(text: "Change primary colors to brand standard.")
    },
    {
      "client": "GA MALL",
      "initials": "PC",
      "name": "Pavithra C",
      "task": "Website",
      "duration": "1week",
      "status": "SUBMITTED",
      "action": "ACTION",
      "controller": TextEditingController(text: "")
    },
    {
      "client": "BRAHMOS",
      "initials": "AD",
      "name": "Arun",
      "task": "Meta Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "REJECTED",
      "controller": TextEditingController(text: "Incorrect campaign objectives chosen.")
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "ACTION",
      "controller": TextEditingController(text: "")
    },
    {
      "client": "GA MALL",
      "initials": "PC",
      "name": "Pavithra C",
      "task": "Website",
      "duration": "1week",
      "status": "SUBMITTED",
      "action": "APPROVED",
      "controller": TextEditingController(text: "")
    },
    {
      "client": "JYOTHI",
      "initials": "SS",
      "name": "Susan",
      "task": "Instagram Ads",
      "duration": "1 Month",
      "status": "SUBMITTED",
      "action": "ACTION",
      "controller": TextEditingController(text: "")
    }
  ];

  final List<String> actionOptions = ["ACTION", "APPROVED", "REWORK", "REJECTED"];

  @override
  void dispose() {
    for (var row in reviewData) {
      (row["controller"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── REACTIVE DATA FILTERING ENGINE ──
    List<Map<String, dynamic>> filteredReviews = reviewData.where((row) {
      if (!_isFilterMenuOpen || activeFilter == "All") return true;
      return row["action"].toString().toUpperCase() == activeFilter.toUpperCase();
    }).toList();

    return AdminLayout(
      pageTitle: "Manager Review",
      currentRoute: "/manager-review",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Header & Description ──
          const Text(
            "Manager Review",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            "Demonstrated consistent performance, professionalism, and dedication towards assigned responsibilities.",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 28),

          // ── Work Review Layout Container Data Grid ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Data Grid Control Ribbon Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Work review",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      Row(
                        children: [
                          // ── DYNAMIC HORIZONTAL FILTER MENU TABS ──
                          AnimatedVisibility(
                            visible: _isFilterMenuOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFilterTab("All"),
                                _buildFilterTab("Action"),
                                _buildFilterTab("Approved"),
                                _buildFilterTab("Rework"),
                                _buildFilterTab("Rejected"),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          
                          // ── FILTER VISIBILITY TOGGLE BUTTON ──
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isFilterMenuOpen = !_isFilterMenuOpen;
                                if (!_isFilterMenuOpen) {
                                  activeFilter = "All"; // Resets filter layout cleanly when hidden
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

                // 2. Table Column Heading Titles Row
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
                      Expanded(flex: 2, child: Text("STATUS", style: _headerStyle)),
                      Expanded(flex: 2, child: Text("ACTION", style: _headerStyle)),
                      Expanded(flex: 4, child: Text("COMMENT", style: _headerStyle)),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                // 3. Scrollable List of Work Review Submissions
                SizedBox(
                  height: 480,
                  child: filteredReviews.isEmpty
                      ? const Center(
                          child: Text(
                            "No review logs found matching this active filter status.",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredReviews.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final row = filteredReviews[index];
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
                                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                        child: const Text(
                                          "SUBMITTED",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A), letterSpacing: 0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildInteractiveActionDropdown(row, index),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                                      child: TextField(
                                        controller: row["controller"] as TextEditingController,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                        decoration: InputDecoration(
                                          hintText: "Write manager review feedback...",
                                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                          fillColor: const Color(0xFFF8FAFC),
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade200)),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
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

                // 4. Data Ledger Pagination Footer Area Component
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Showing 1 to ${filteredReviews.length} of ${filteredReviews.length} review records", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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

  Widget _buildInteractiveActionDropdown(Map<String, dynamic> row, int index) {
    String currentAction = row["action"].toString().toUpperCase();

    Color containerColor = const Color(0xFFF1F5F9);
    Color textColor = const Color(0xFF475569);

    if (currentAction == "APPROVED") {
      containerColor = const Color(0xFFDCFCE7); 
      textColor = const Color(0xFF16A34A);      
    } else if (currentAction == "REWORK") {
      containerColor = const Color(0xFFFEF3C7); 
      textColor = const Color(0xFFD97706);      
    } else if (currentAction == "REJECTED") {
      containerColor = const Color(0xFFFEE2E2); 
      textColor = const Color(0xFFDC2626);      
    }

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(4),
        border: currentAction == "ACTION" ? Border.all(color: const Color(0xFFCBD5E1)) : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: actionOptions.contains(row["action"]) ? row["action"] : actionOptions.first,
          icon: Icon(Icons.arrow_drop_down, color: textColor, size: 16),
          dropdownColor: Colors.white,
          alignment: Alignment.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 0.3),
          items: actionOptions.map((String choice) {
            return DropdownMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              row["action"] = newValue!;
              
              final TextEditingController targetController = row["controller"] as TextEditingController;
              if (targetController.text.isEmpty) {
                if (newValue == "APPROVED") {
                  targetController.text = "Approved asset distributions.";
                } else if (newValue == "REWORK") {
                  targetController.text = "Needs adjustments.";
                } else if (newValue == "REJECTED") {
                  targetController.text = "Declined due to specification errors.";
                }
              }
            });
          },
        ),
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