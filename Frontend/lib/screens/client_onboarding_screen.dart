import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../layouts/admin_layout.dart';
import 'client_history_screen.dart';

class ClientOnboardingScreen extends StatefulWidget {
  // ── Pass an existing client id to EDIT that client ────────────────────────────
  // Pass null to create a brand-new client
  final int? clientId;

  const ClientOnboardingScreen({super.key, this.clientId});

  @override
  State<ClientOnboardingScreen> createState() => _ClientOnboardingScreenState();
}

class _ClientOnboardingScreenState extends State<ClientOnboardingScreen> {

  static const String _baseUrl = 'http://localhost:3000/api';

  // Text input controllers
  final companyNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  // ── Bank Details controllers (now editable & saved to backend) ───────────────
  final bankAccountNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final bankIfscController = TextEditingController();

  String selectedIndustry = 'Financial Services';

  // ── Current client id (null until first save) ────────────────────────────────
  int? _clientId;
  String _currentStatus = 'draft';
  int _completionPercent = 0;

  bool _loadingClient = false;
  bool _savingDraft = false;
  bool _completing  = false;

  // ── Credentials table data (filtered by THIS client only) ────────────────────
  List<Map<String, dynamic>> _credentials = [];
  bool _loadingCredentials = true;

  @override
  void initState() {
    super.initState();
    _clientId = widget.clientId;
    if (_clientId != null) {
      _loadClient();
    }
    _fetchCredentials();
  }

  @override
  void dispose() {
    companyNameController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    addressController.dispose();
    bankAccountNameController.dispose();
    bankNameController.dispose();
    bankAccountNumberController.dispose();
    bankIfscController.dispose();
    super.dispose();
  }

  // ── Navigate back to Client History page (after Save Draft / Complete) ─────────
  void _goToClientHistory() {
    if (!mounted) return;
    // Small delay so the success snackbar is visible before navigating away
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // returns to ClientHistoryScreen (pushed via Navigator.push)
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientHistoryScreen()),
        );
      }
    });
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? const Color(0xFF16A34A) : Colors.redAccent,
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── LOAD existing client (when editing) ────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════
  Future<void> _loadClient() async {
    setState(() => _loadingClient = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/clients/$_clientId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final c = body['data'];
        setState(() {
          companyNameController.text   = c['company_name'] ?? '';
          contactPersonController.text = c['contact_person'] ?? '';
          emailController.text         = c['email'] ?? '';
          addressController.text       = c['address'] ?? '';
          bankAccountNameController.text   = c['bank_account_name'] ?? '';
          bankNameController.text          = c['bank_name'] ?? '';
          bankAccountNumberController.text = c['bank_account_number'] ?? '';
          bankIfscController.text          = c['bank_ifsc'] ?? '';
          selectedIndustry              = c['industry'] ?? 'Financial Services';
          _currentStatus                = c['status'] ?? 'draft';
          _completionPercent            = c['completion_percent'] ?? 0;
          _loadingClient = false;
        });
      } else {
        setState(() => _loadingClient = false);
        _showSnack('Failed to load client details');
      }
    } catch (e) {
      setState(() => _loadingClient = false);
      _showSnack('Cannot connect to server');
    }
  }

  // ── Lightweight refresh: only fetch the completion % (after credential changes) ─
  Future<void> _refreshCompletionPercent() async {
    if (_clientId == null) return;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/clients/$_clientId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _completionPercent = body['data']['completion_percent'] ?? _completionPercent;
        });
      }
    } catch (_) {
      // silent — non-critical UI refresh
    }
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── CLIENT (company) API CALLS ─────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> _clientPayload(String status) {
    return {
      'companyName':   companyNameController.text.trim(),
      'industry':      selectedIndustry,
      'contactPerson': contactPersonController.text.trim(),
      'email':         emailController.text.trim(),
      'address':       addressController.text.trim(),
      'bankAccountName':   bankAccountNameController.text.trim(),
      'bankName':          bankNameController.text.trim(),
      'bankAccountNumber': bankAccountNumberController.text.trim(),
      'bankIfsc':          bankIfscController.text.trim(),
      'status':        status,
    };
  }

  // ── SAVE DRAFT button ─────────────────────────────────────────────────────────
  Future<void> _saveDraft() async {
    if (companyNameController.text.trim().isEmpty) {
      _showSnack('Please enter the Company Legal Name first');
      return;
    }

    setState(() => _savingDraft = true);
    try {
      http.Response response;
      // Keep status as 'pending' if already past draft, otherwise 'draft'
      final status = (_currentStatus == 'draft') ? 'draft' : _currentStatus;

      if (_clientId == null) {
        response = await http.post(
          Uri.parse('$_baseUrl/clients'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_clientPayload('draft')),
        );
      } else {
        response = await http.put(
          Uri.parse('$_baseUrl/clients/$_clientId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_clientPayload(status)),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (_clientId == null && body['data'] != null) {
          setState(() {
            _clientId = body['data']['id'];
            _currentStatus = 'draft';
            // First save -> backend returns 30% base completion
            _completionPercent = body['data']['completion_percent'] ?? 30;
          });
          _fetchCredentials(); // now that client exists, load (empty) credentials list
        } else if (body['completion_percent'] != null) {
          setState(() => _completionPercent = body['completion_percent']);
        }
        _showSnack('Draft saved successfully', success: true);
        _goToClientHistory(); // ✅ move to Client History page after saving
      }
    } catch (e) {
      _showSnack('Cannot connect to server');
    } finally {
      setState(() => _savingDraft = false);
    }
  }

  // ── COMPLETE REGISTRATION button ──────────────────────────────────────────────
  Future<void> _completeRegistration() async {
    if (companyNameController.text.trim().isEmpty ||
        contactPersonController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _showSnack('Please fill Company Name, Contact Person and Email before completing registration');
      return;
    }

    setState(() => _completing = true);
    try {
      http.Response response;
      if (_clientId == null) {
        response = await http.post(
          Uri.parse('$_baseUrl/clients'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_clientPayload('complete')),
        );
      } else {
        response = await http.put(
          Uri.parse('$_baseUrl/clients/$_clientId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_clientPayload('complete')),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (_clientId == null && body['data'] != null) {
          _clientId = body['data']['id'];
        }
        setState(() {
          _currentStatus = 'complete';
          _completionPercent = 100; // ✅ Complete Registration -> always 100%
        });
        _showSnack('Registration completed — 100% complete', success: true);
        _goToClientHistory(); // ✅ move to Client History page after completing
      }
    } catch (e) {
      _showSnack('Cannot connect to server');
    } finally {
      setState(() => _completing = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── CREDENTIALS API CALLS (filtered by THIS client_id) ──────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════

  // ── FETCH credentials list for this client only ───────────────────────────────
  Future<void> _fetchCredentials() async {
    if (_clientId == null) {
      // No client saved yet — nothing to fetch
      setState(() { _credentials = []; _loadingCredentials = false; });
      return;
    }
    setState(() => _loadingCredentials = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/credentials?clientId=$_clientId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _credentials = List<Map<String, dynamic>>.from(body['data']);
          _loadingCredentials = false;
        });
      } else {
        setState(() => _loadingCredentials = false);
        _showSnack('Failed to load credentials');
      }
    } catch (e) {
      setState(() => _loadingCredentials = false);
      _showSnack('Cannot connect to server');
    }
  }

  // ── CREATE credential — auto-saves client first if not yet saved ─────────────
  // Returns null on success, error message on failure
  Future<String?> _createCredential(Map<String, dynamic> data) async {
    // Ensure client exists before attaching a credential to it
    if (_clientId == null) {
      if (companyNameController.text.trim().isEmpty) {
        return 'Please enter the Company Legal Name and Save Draft first, before adding credentials.';
      }
      try {
        final clientResp = await http.post(
          Uri.parse('$_baseUrl/clients'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_clientPayload('draft')),
        );
        if (clientResp.statusCode == 201) {
          final body = jsonDecode(clientResp.body);
          _clientId = body['data']['id'];
        } else {
          return 'Failed to create client record before saving credential';
        }
      } catch (e) {
        return 'Cannot connect to server';
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/credentials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({...data, 'clientId': _clientId}),
      );
      if (response.statusCode == 201) {
        await _fetchCredentials();
        await _refreshCompletionPercent(); // ✅ update % badge after each credential added
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['message'] ?? 'Failed to add credential';
      }
    } catch (e) {
      return 'Cannot connect to server';
    }
  }

  // ── UPDATE credential ─────────────────────────────────────────────────────────
  Future<String?> _updateCredential(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/credentials/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        await _fetchCredentials();
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['message'] ?? 'Failed to update credential';
      }
    } catch (e) {
      return 'Cannot connect to server';
    }
  }

  // ── DELETE credential ──────────────────────────────────────────────────────────
  Future<void> _deleteCredential(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/credentials/$id'));
      if (response.statusCode == 200) {
        await _fetchCredentials();
        await _refreshCompletionPercent();
        _showSnack('Credential deleted', success: true);
      } else {
        _showSnack('Failed to delete credential');
      }
    } catch (e) {
      _showSnack('Cannot connect to server');
    }
  }

  // ── Date formatting helpers — converts MySQL datetime to local system time ──────
  // mysql2 may return either "2026-06-12 14:30:00" OR "2026-06-12T14:30:00.000Z"
  // depending on driver/version, so detect which format we got before converting.
  DateTime? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      if (iso.contains('T')) {
        // Already ISO 8601 (with or without trailing Z) — parse as-is
        return DateTime.parse(iso).toLocal();
      }
      // "2026-06-12 14:30:00" — MySQL DATETIME with space separator, treat as UTC
      return DateTime.parse(iso.replaceFirst(' ', 'T') + 'Z').toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String? isoDate) {
    final dt = _parseDate(isoDate);
    if (dt == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(String? isoDate) {
    final dt = _parseDate(isoDate);
    if (dt == null) return '';
    final hour   = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm   = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Client Onboarding",
      currentRoute: "/client-history",
      child: _loadingClient
          ? const Center(child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(color: Color(0xFF0052CC)),
            ))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title & Action Buttons Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Client Onboarding",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Text(
                      "Register a new enterprise partner and configure their service ecosystem.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    if (_clientId != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('$_completionPercent% complete',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0052CC))),
                      ),
                    ],
                  ]),
                ],
              ),
              Row(
                children: [
                  // Back to history
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text("Back", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _savingDraft ? null : _saveDraft,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: _savingDraft
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF475569)),
                          )
                        : const Text("Save Draft", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _completing ? null : _completeRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      elevation: 0,
                    ),
                    child: _completing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Complete Registration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),

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

                    // ── Bank Details — now editable & saved to backend ──────
                    _buildFormCard(
                      title: "Bank Details",
                      subtitle: "Configure default accounts for invoicing integrations.",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: "Account Holder Name",
                                  hint: "e.g. MarqueMetrics LLC",
                                  controller: bankAccountNameController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  label: "Bank Name",
                                  hint: "e.g. First National Bank",
                                  controller: bankNameController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: "A/C Number",
                                  hint: "e.g. 1234567891234",
                                  controller: bankAccountNumberController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  label: "IFSC / Routing",
                                  hint: "e.g. FNBBUS33",
                                  controller: bankIfscController,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                              child: LinearProgressIndicator(
                                value: _completionPercent / 100,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF002266),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "$_completionPercent% of profile completed",
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
                    "Manage and securely store all account credentials for THIS client only.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _fetchCredentials,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text("Refresh", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
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

                if (_loadingCredentials)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF0052CC))),
                  )
                else if (_clientId == null)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Save the client details first (Save Draft), then add credentials here.',
                        style: TextStyle(color: Color(0xFF94A3B8)))),
                  )
                else if (_credentials.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No credentials yet for this client. Click "Add Credential" to create one.',
                        style: TextStyle(color: Color(0xFF94A3B8)))),
                  )
                else
                  ..._credentials.asMap().entries.expand((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    final row = _buildCredentialRow(
                      c['id'],
                      c['username'] ?? '',
                      c['password'] ?? '',
                      c['platform'] ?? '',
                      c['contact_number'] ?? '',
                      c['email'] ?? '',
                      _formatDate(c['updated_at']?.toString()),
                      _formatTime(c['updated_at']?.toString()),
                    );
                    if (i < _credentials.length - 1) {
                      return [row, const Divider(height: 1, color: Color(0xFFE2E8F0))];
                    }
                    return [row];
                  }),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── ADDED POPUP DIALOG OVERLAY METHOD WITH STATEFUL DROPDOWN IMPLEMENTATION ──
  void _showAddCredentialDialog(BuildContext context, {Map<String, dynamic>? existing}) {
    final isEdit = existing != null;

    // ── Master list of platform options ──────────────────────────────────────────
    const basePlatforms = [
      'Facebook', 'Instagram', 'YouTube', 'Google Ads', 'Meta Ads',
      'Facebook Login', 'Instagram Login', 'LinkedIn Login', 'YouTube Login',
      'Google Business Profile', 'Server Login',
    ];

    // ── Platforms already used by THIS client (so they can't be picked again) ─────
    final usedPlatforms = _credentials
        .map((c) => c['platform']?.toString() ?? '')
        .where((p) => !isEdit || p != existing!['platform']) // allow keeping own platform when editing
        .toSet();

    // ── Build available dropdown items: hide already-used platforms, always show "Others"
    final availablePlatforms = [
      'Select',
      ...basePlatforms.where((p) => !usedPlatforms.contains(p)),
      'Others',
    ];

    // ── Determine initial dropdown value ───────────────────────────────────────────
    final existingPlatform = existing?['platform'] ?? '';
    final isCustomPlatform = isEdit && existingPlatform.isNotEmpty && !basePlatforms.contains(existingPlatform);

    String dialogSelectedPlatform = isEdit
        ? (isCustomPlatform ? 'Others' : existingPlatform)
        : 'Select';

    final otherPlatformCtrl = TextEditingController(text: isCustomPlatform ? existingPlatform : '');

    final clientNameCtrl = TextEditingController(text: existing?['username'] ?? '');
    final userNameCtrl   = TextEditingController(text: existing?['username'] ?? '');
    final passwordCtrl   = TextEditingController(text: existing?['password'] ?? '');
    final contactCtrl    = TextEditingController(text: existing?['contact_number'] ?? '');
    final emailCtrl      = TextEditingController(text: existing?['email'] ?? '');

    bool isSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            Future<void> handleSubmit() async {
              final finalPlatform = dialogSelectedPlatform == 'Others'
                  ? otherPlatformCtrl.text.trim()
                  : dialogSelectedPlatform;

              if (userNameCtrl.text.trim().isEmpty ||
                  passwordCtrl.text.trim().isEmpty ||
                  dialogSelectedPlatform == 'Select' ||
                  finalPlatform.isEmpty) {
                setDialogState(() => dialogError = dialogSelectedPlatform == 'Others' && finalPlatform.isEmpty
                    ? 'Please specify the platform name'
                    : 'Please fill all required fields (*)');
                return;
              }

              setDialogState(() { isSubmitting = true; dialogError = null; });

              final payload = {
                'username':      userNameCtrl.text.trim(),
                'password':      passwordCtrl.text.trim(),
                'platform':      finalPlatform,
                'contactNumber': contactCtrl.text.trim(),
                'email':         emailCtrl.text.trim(),
              };

              final error = isEdit
                  ? await _updateCredential(existing!['id'], payload)
                  : await _createCredential(payload);

              if (error == null) {
                if (context.mounted) Navigator.pop(context);
                setState(() {}); // refresh completion % badge
                _showSnack(isEdit ? 'Credential updated' : 'Credential added', success: true);
              } else {
                setDialogState(() { isSubmitting = false; dialogError = error; });
              }
            }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
            color: Colors.white,
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
                        Text(
                          isEdit ? "Edit Client Credential" : "Client Credential",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                          onPressed: isSubmitting ? null : () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1),
                    ),

                    // ── ERROR BANNER inside dialog ───────────────────────────
                    if (dialogError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(dialogError!,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Form Inputs Grid Layout Panel
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogInputField(label: "Client Name *", hint: "", controller: clientNameCtrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDialogDropdownField(
                            label: "Platform *",
                            value: dialogSelectedPlatform,
                            items: availablePlatforms,
                            onChanged: (val) {
                              setDialogState(() {
                                dialogSelectedPlatform = val!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // ── "Others" custom platform name field ────────────────────────
                    if (dialogSelectedPlatform == 'Others') ...[
                      const SizedBox(height: 16),
                      _buildDialogInputField(
                        label: "Specify Platform Name *",
                        hint: "e.g. Pinterest, Twitter/X, Custom CRM",
                        controller: otherPlatformCtrl,
                      ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogInputField(label: "User Name *", hint: "", controller: userNameCtrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDialogInputField(label: "Password *", hint: "", obscureText: true, controller: passwordCtrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogInputField(label: "Contact Number *", hint: "", controller: contactCtrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDialogInputField(label: "Email *", hint: "", controller: emailCtrl),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Bottom Action Panel Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                            backgroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
  Widget _buildDialogInputField({required String label, required String hint, bool obscureText = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
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
    final safeItems = items.contains(value) ? items : [value, ...items];
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
              items: safeItems.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Static TextStyle token reference for credential tables
  static const TextStyle _tableHeaderStyle = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5,
  );

  // Helper Widget: Builds crisp Custom Credential Layout List Rows
  Widget _buildCredentialRow(int id, String username, String pass, String platform, String phone, String email, String date, String time) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(username, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Expanded(flex: 3, child: Text('•' * 12, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), letterSpacing: 1.5))),
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
                  onPressed: () => _showAddCredentialDialog(context, existing: {
                    'id': id, 'username': username, 'password': pass,
                    'platform': platform, 'contact_number': phone, 'email': email,
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFCBD5E1)),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Credential'),
                      content: Text('Remove credential for "$username"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteCredential(id);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
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