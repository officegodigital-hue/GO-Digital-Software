import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Current active filter tab tracker
  String activeFilter = "All";

  // ── FILTER VISIBILITY TOGGLE TRACKER FLAG ──
  bool _isFilterMenuOpen = false;

  // Notification Data Model matching the mockups exactly
  final List<Map<String, dynamic>> notificationLogs = [
    {
      "initials": "AD",
      "name": "Arun",
      "message": "Task \"Homepage Banner Design\" Has Been Submitted For Review.",
      "isUnread": true,
      "isFavorite": false,
      "time": "Just Now",
      "isArchived": false
    },
    {
      "initials": "SS",
      "name": "Susan",
      "message": "Deliverables For The Social Media Campaign Have Been Uploaded Successfully.",
      "isUnread": false,
      "isFavorite": true,
      "time": "10.30am",
      "isArchived": false
    },
    {
      "initials": "PC",
      "name": "Pavithra C",
      "message": "Unable To Access Client Assets Required For Today's Deliverables.",
      "isUnread": false,
      "isFavorite": false,
      "time": "10.00am",
      "isArchived": false
    },
    {
      "initials": "AD",
      "name": "Arun",
      "message": "Daily Work Report Has Been Submitted To The Admin Panel.",
      "isUnread": true,
      "isFavorite": false,
      "time": "Just Now",
      "isArchived": false
    },
    {
      "initials": "SS",
      "name": "Susan",
      "message": "The Campaign Creatives Need Final Confirmation Before Publishing.",
      "isUnread": false,
      "isFavorite": true,
      "time": "10.30am",
      "isArchived": true // Mock sample for Achive group filtering
    },
    {
      "initials": "PC",
      "name": "Pavithra C",
      "message": "Delay Expected Due To Pending Feedback From The Client Side.",
      "isUnread": false,
      "isFavorite": false,
      "time": "10.00am",
      "isArchived": false
    },
    {
      "initials": "AD",
      "name": "Arun",
      "message": "SEO Optimization Task Completed And Moved To Testing Stage.",
      "isUnread": true,
      "isFavorite": false,
      "time": "Just Now",
      "isArchived": false
    },
    {
      "initials": "SS",
      "name": "Susan",
      "message": "Additional Time Requested To Complete The Branding Presentation Updates.",
      "isUnread": false,
      "isFavorite": false,
      "time": "10.30am",
      "isArchived": false
    },
    {
      "initials": "PC",
      "name": "Pavithra C",
      "message": "Website UI Revisions Are Completed And Ready For Approval.",
      "isUnread": false,
      "isFavorite": false,
      "time": "10.00am",
      "isArchived": false
    }
  ];

  @override
  Widget build(BuildContext context) {
    // ── REACTIVE NOTIFICATION FILTER MATRIX ──
    List<Map<String, dynamic>> filteredNotifications = notificationLogs.where((log) {
      if (!_isFilterMenuOpen || activeFilter == "All") return true;
      if (activeFilter == "Unread") return log["isUnread"] == true;
      if (activeFilter == "Read") return log["isUnread"] == false;
      if (activeFilter == "Achive") return log["isArchived"] == true;
      if (activeFilter == "Favorite") return log["isFavorite"] == true;
      return true;
    }).toList();

    return AdminLayout(
      pageTitle: "Notifications",
      currentRoute: "/notifications",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Header Banner ──
          const Text(
            "Notification",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            "Never miss an update — get real-time notifications on all your activities.",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 28),

          // ── Main Content Alert Workspace Box ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Interactive Tab Controls Ribbon Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "List of Notification",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      Row(
                        children: [
                          // Animated Visibility rendering for filtering options row tabs
                          AnimatedVisibility(
                            visible: _isFilterMenuOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFilterTab("All"),
                                _buildFilterTab("Unread"),
                                _buildFilterTab("Read"),
                                _buildFilterTab("Achive"),
                                _buildFilterTab("Favorite"),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          
                          // ── DYNAMIC INTERACTIVE FILTER MASTER TOGGLE ──
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isFilterMenuOpen = !_isFilterMenuOpen;
                                if (!_isFilterMenuOpen) {
                                  activeFilter = "All"; // Resets condition cleanly when hidden
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
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // 2. Fixed Index Title Heading Headers
                Container(
                  color: Colors.white,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      SizedBox(width: 150, child: Text("EMPLOYEE NAME", style: _headerStyle)),
                      Expanded(child: Text("MESSAGES", style: _headerStyle)),
                      SizedBox(width: 120, child: Text("TIME", textAlign: TextAlign.center, style: _headerStyle)),
                      SizedBox(width: 80, child: Text("REMOVE", textAlign: TextAlign.center, style: _headerStyle)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // 3. Scrollable List of Alerts
                SizedBox(
                  height: 520,
                  child: filteredNotifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No notifications found in this group category.",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredNotifications.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          itemBuilder: (context, index) {
                            final log = filteredNotifications[index];
                            final bool isUnread = log["isUnread"];

                            return Container(
                              height: 58,
                              color: isUnread ? const Color(0xFFEFF6FF).withOpacity(0.4) : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: const BoxDecoration(color: Color(0xFFDCE4F7), shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text(
                                            log["initials"],
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4A69B3)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            log["name"],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            log["message"],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isUnread ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              log["isFavorite"] = !log["isFavorite"];
                                            });
                                          },
                                          icon: Icon(
                                            log["isFavorite"] ? Icons.star_rounded : Icons.star_border_rounded,
                                            color: log["isFavorite"] ? const Color(0xFF0052CC) : const Color(0xFFCBD5E1),
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      log["time"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isUnread ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 80,
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            notificationLogs.remove(log);
                                          });
                                        },
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                        hoverColor: Colors.red.shade50,
                                        splashRadius: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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