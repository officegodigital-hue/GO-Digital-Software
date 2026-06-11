import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  // Master List containing User Access Authorization Records
  final List<Map<String, dynamic>> employeeUsers = [
    {"name": "Pavithra C", "initials": "PC", "id": "173549695", "role": "Graphic Designer", "isActive": true},
    {"name": "Susan", "initials": "SS", "id": "173540695", "role": "Digital Marketing", "isActive": false},
    {"name": "Arun", "initials": "AD", "id": "173540695", "role": "Video Editor", "isActive": true},
    {"name": "Arun", "initials": "AD", "id": "173540695", "role": "Graphic Designer", "isActive": true},
  ];

  // Triggers the custom popup sheet modeled after your blueprint design metrics
  void _showCreateUserModal(BuildContext context) {
    final firstNameController = TextEditingController();
    final middleNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final staffIdController = TextEditingController();
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = "UI/ UX Designer";
    bool sendEmail = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 24,
              child: Container(
                width: 680,
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Structural Heading Title & Dismiss Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Create Staff User",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                          splashRadius: 20,
                        )
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),

                    // Name Grid Layout Inputs
                    Row(
                      children: [
                        Expanded(child: _buildModalInputField("First Name *", firstNameController, hint: "Pavithra")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModalInputField("Middle Name", middleNameController, hint: "C")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModalInputField("Last Name *", lastNameController, hint: "Employee")),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Technical Attributes Row Mappings
                    Row(
                      children: [
                        Expanded(child: _buildModalInputField("Staff ID *", staffIdController, hint: "4509836")),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Role *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                              const SizedBox(height: 6),
                              Container(
                                height: 38,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedRole,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                                    items: ["UI/ UX Designer", "Graphic Designer", "Digital Marketing", "Video Editor", "Web Developer"]
                                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                        .toList(),
                                    onChanged: (val) => setModalState(() => selectedRole = val!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contact Vector Grid Parameters
                    Row(
                      children: [
                        Expanded(child: _buildModalInputField("Email Address *", emailController, hint: "pavithrafshn@gmail.com")),
                        const SizedBox(width: 16),
                        Expanded(child: _buildModalInputField("Username *", usernameController, hint: "Pavithra")),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Administrative Credentials Section
                    _buildModalInputField("Password *", passwordController, hint: "Pavithra123", isPassword: true),
                    const SizedBox(height: 20),

                    // Static Informational Layer Warning Notice Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF1D4ED8)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Password", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
                                SizedBox(height: 4),
                                Text(
                                  "Password will be autogenerated and emailed to this staff user upon creation. Security policies require a change upon first login.",
                                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mail Dispatch Confirmation Checkbox row
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: sendEmail,
                            activeColor: const Color(0xFF0052CC),
                            onChanged: (val) => setModalState(() => sendEmail = val!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("Send welcome email to staff user", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Modal Commit Action Trigger Buttons Layout Footer panel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          child: const Text("Cancel", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (firstNameController.text.isNotEmpty || staffIdController.text.isNotEmpty) {
                              setState(() {
                                String fullname = "${firstNameController.text} ${middleNameController.text}".trim();
                                if (fullname.isEmpty) fullname = "New Employee";
                                String init = firstNameController.text.isNotEmpty ? firstNameController.text.substring(0, 1).toUpperCase() : "NE";
                                
                                employeeUsers.add({
                                  "name": fullname,
                                  "initials": init,
                                  "id": staffIdController.text.isNotEmpty ? staffIdController.text : "173540000",
                                  "role": selectedRole,
                                  "isActive": true
                                });
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text("Create", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Admin Panel",
      currentRoute: "/admin-panel",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Header Action Controller Ribbon ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "User Access Management",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Securely manage user roles, permissions, and access across the platform.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateUserModal(context), // Launches designer modal setup overlay sheet
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  elevation: 0,
                ),
                label: const Text("Create Employee User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Main Core Table Collection Field ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Datagrid Column Heading Title Bar Strip Index
                Container(
                  color: const Color(0xFFF8FAFC),
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      Expanded(flex: 4, child: Text("Employee Name", style: _headingStyle)),
                      Expanded(flex: 3, child: Text("Employee ID", style: _headingStyle)),
                      Expanded(flex: 4, child: Text("Role", style: _headingStyle)),
                      Expanded(flex: 2, child: Text("Status", textAlign: TextAlign.center, style: _headingStyle)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Scroll Container Mapping Collection Items
                SizedBox(
                  height: 420,
                  child: ListView.separated(
                    itemCount: employeeUsers.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) {
                      final item = employeeUsers[index];
                      final bool active = item["isActive"];

                      return Container(
                        height: 62,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        color: Colors.white,
                        child: Row(
                          children: [
                            // Profile Avatar Segment
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(color: Color(0xFFDCE4F7), shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item["initials"],
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4A69B3)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item["name"],
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                            // Employee ID Field Segment
                            Expanded(
                              flex: 3,
                              child: Text(
                                item["id"],
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                              ),
                            ),
                            // Department Role Designation Segment
                            Expanded(
                              flex: 4,
                              child: Text(
                                item["role"],
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                              ),
                            ),
                            // Micro Status Label Badge Segment
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: active ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    active ? "ACTIVE" : "IN - ACTIVE",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: active ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

  // ── POPUP COMPONENT SUB-FIELD INPUT CONSTRUCTOR ──
  Widget _buildModalInputField(String label, TextEditingController controller, {required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
            ),
          ),
        ),
      ],
    );
  }

  static const TextStyle _headingStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569));
}