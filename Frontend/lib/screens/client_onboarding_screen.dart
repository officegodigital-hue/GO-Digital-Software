import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class ClientOnboardingScreen extends StatefulWidget {
  const ClientOnboardingScreen({super.key});

  @override
  State<ClientOnboardingScreen> createState() => _ClientOnboardingScreenState();
}

class _ClientOnboardingScreenState extends State<ClientOnboardingScreen> {
  // Text input controllers
  final companyNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  
  String selectedIndustry = 'Financial Services';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Client Onboarding",
      currentRoute: "/client",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title & Action Buttons Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Client Onboarding",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Register a new enterprise partner and configure their service ecosystem.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text("Save Draft", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text("Complete Registration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Progress Steps Indicator Banner ──
          _buildProgressStepper(),

          const SizedBox(height: 24),

          // ── Main Content Split View (Form Panel + Sidebar Card) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section: Main Form Panels
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildFormCard(
                      title: "Primary Company Details",
                      subtitle: "Legal information for billing and contract management.",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: "Company Legal Name",
                                  hint: "e.g. Acme Corporation",
                                  controller: companyNameController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdownField(
                                  label: "Industry Vertical",
                                  value: selectedIndustry,
                                  items: ['Financial Services', 'Technology', 'Healthcare', 'Retail'],
                                  onChanged: (val) => setState(() => selectedIndustry = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: "Primary Contact Person",
                                  hint: "Jane Doe",
                                  controller: contactPersonController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  label: "Business Email Address",
                                  hint: "jane@company.com",
                                  controller: emailController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: "Company Headquarters Address",
                            hint: "Street, City, Country, ZIP",
                            controller: addressController,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Bank Details Container Rendered Perfectly to Image Layout ──
                    _buildFormCard(
                      title: "Bank Details (Display)",
                      subtitle: "Configure default accounts for invoicing integrations.",
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBankDetailItem("Name", "MarqueMetrics\nLLC"),
                            _buildBankDetailItem("Bank", "First National\nBank"),
                            _buildBankDetailItem("A/C Number", "**** **** 8291"),
                            _buildBankDetailItem("IFSC / Routing", "FNBBUS33"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Section: Sidebar Target Metric Tracker Card
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0044B3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Partner Excellence",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "GoDigital partners represent the top 5% of digital-first enterprises. Ensuring accurate data entry here streamlines the entire contract lifecycle.",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003399),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
                                SizedBox(width: 8),
                                Text("Onboarding Verification", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.35,
                                minHeight: 6,
                                backgroundColor: Color(0xFF002266),
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "35% of profile completed",
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ── CLIENT CREDENTIAL DETAILS SECTION ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Client Credential Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Manage and securely store all client account credentials in one place.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text("Save Draft", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddCredentialDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      elevation: 0,
                    ),
                    label: const Text("Add Credential", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Credentials View Data Grid ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header Labels
                Container(
                  color: const Color(0xFFEAEFF8),
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: Text("USER NAME", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("PASSWORD", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("PLATFORM", style: _tableHeaderStyle)),
                      Expanded(flex: 4, child: Text("CONTACT NUMBER / EMAIL", style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text("LAST UPDATED", style: _tableHeaderStyle)),
                      Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text("ACTIONS", style: _tableHeaderStyle))),
                    ],
                  ),
                ),
                
                // Data Rows Block
                _buildCredentialRow("client.fb.account", "************", "Facebook Login", "+91 98765 43210", "handler@example.com", "May 20, 2024", "10:30 AM"),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildCredentialRow("client.ig.account", "************", "Instagram Login", "+91 98765 43210", "handler@example.com", "May 20, 2024", "10:30 AM"),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildCredentialRow("client.linkedin", "************", "LinkedIn Login", "+91 98765 43210", "handler@example.com", "May 20, 2024", "10:30 AM"),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildCredentialRow("client.youtube", "************", "YouTube Login", "+91 98765 43210", "handler@example.com", "May 20, 2024", "10:30 AM"),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildCredentialRow("client.gbp", "************", "Google Business Profile", "+91 98765 43210", "handler@example.com", "May 20, 2024", "10:30 AM"),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildCredentialRow("server.client.com", "************", "Server Login", "+91 98765 43210", "handler@example.com", "May 20, 2024", "10:30 AM"),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── ADDED POPUP DIALOG OVERLAY METHOD WITH STATEFUL DROPDOWN IMPLEMENTATION ──
  void _showAddCredentialDialog(BuildContext context) {
    String dialogSelectedPlatform = 'Select'; // Default placeholder matching mockup

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
            color: Colors.white, // Moved inside BoxDecoration
            borderRadius: BorderRadius.circular(8),
            ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog Top Header Bar with Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Client Credential",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
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

                    // Form Inputs Grid Layout Panel
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogInputField(label: "Client Name *", hint: ""),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDialogDropdownField(
                            label: "Platform *",
                            value: dialogSelectedPlatform,
                            items: ['Select', 'Facebook', 'Instagram', 'YouTube', 'Google Ads', 'Meta Ads'],
                            onChanged: (val) {
                              setDialogState(() {
                                dialogSelectedPlatform = val!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogInputField(label: "User Name *", hint: ""),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDialogInputField(label: "Password *", hint: "", obscureText: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogInputField(label: "Contact Number *", hint: ""),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDialogInputField(label: "Email *", hint: ""),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),

                    // Bottom Action Panel Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text("Cancel", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B), // Matches exact mockup dark tint tone color
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  // Dialog Input Component Constructor Block
  Widget _buildDialogInputField({required String label, required String hint, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            obscureText: obscureText,
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

  // Dialog Dropdown Menu Component Constructor Block
  Widget _buildDialogDropdownField({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
              items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget: Builds uniform layout grid structures for Bank Details Block
  Widget _buildBankDetailItem(String label, String content) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8A94A6), letterSpacing: 0.3),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), height: 1.3),
          ),
        ],
      ),
    );
  }

  // Static TextStyle token reference for credential tables
  static const TextStyle _tableHeaderStyle = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5,
  );

  // Helper Widget: Builds crisp Custom Credential Layout List Rows
  Widget _buildCredentialRow(String username, String pass, String platform, String phone, String email, String date, String time) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(username, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Expanded(flex: 3, child: Text(pass, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), letterSpacing: 1.5))),
          Expanded(flex: 3, child: Text(platform, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFCBD5E1)),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFCBD5E1)),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Top Step Indicator
  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildStepItem("1", "Core Identity", true),
          _buildStepDivider(),
          _buildStepItem("2", "Service Configuration", false),
          _buildStepDivider(),
          _buildStepItem("3", "Document Vault", false),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step, String title, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0052CC) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(step, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
            Text(isActive ? "ACTIVE" : "PENDING", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isActive ? const Color(0xFF0052CC) : const Color(0xFF94A3B8))),
          ],
        )
      ],
    );
  }

  Widget _buildStepDivider() {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
      ),
    );
  }

  // Helper Widget: Styled Inner Form Cards
  Widget _buildFormCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: const Color(0xFFEAEFF8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(24), child: child),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, required TextEditingController controller, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}