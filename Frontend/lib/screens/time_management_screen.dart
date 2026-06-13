import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../layouts/admin_layout.dart';

// ── Data model ─────────────────────────────────────────────────────────────────

class _TaskEntry {
  int id;
  String taskName;
  String qty;
  String timing;

  _TaskEntry({
    required this.id,
    required this.taskName,
    required this.qty,
    required this.timing,
  });
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class TimeManagerScreen extends StatefulWidget {
  const TimeManagerScreen({super.key});

  @override
  State<TimeManagerScreen> createState() => _TimeManagerScreenState();
}

class _TimeManagerScreenState extends State<TimeManagerScreen> {

  // ── API base URL ──────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://localhost:3000/api';

  bool _loading = true;
  String? _loadError;

  // Task entries (the table rows) — now loaded from backend
  List<_TaskEntry> _entries = [];

  // Dropdown task name options
  final List<String> _taskOptions = [
    'Poster',
    'Video',
    'Meta Ads',
    'Google Ads',
    'Instagram Ads',
    'Website',
    'SEO',
    'Email Campaign',
    'Other',
  ];

  // Segmented duration types options array mapping
  final List<String> _unitOptions = ['mins', 'hrs', 'days'];

  // Form state fields tracking variables
  String? _selectedTaskName;
  final TextEditingController _otherTaskCtrl = TextEditingController();
  final TextEditingController _qtyCtrl     = TextEditingController();
  final TextEditingController _timingValCtrl = TextEditingController();
  String _selectedTimingUnit = 'mins';
  int? _editingId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  @override
  void dispose() {
    _otherTaskCtrl.dispose();
    _qtyCtrl.dispose();
    _timingValCtrl.dispose();
    super.dispose();
  }

  // ── API: FETCH all entries ───────────────────────────────────────────────────
  Future<void> _fetchEntries() async {
    setState(() { _loading = true; _loadError = null; });
    try {
      final response = await http.get(Uri.parse('$_baseUrl/timings'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        setState(() {
          _entries = data.map((e) => _TaskEntry(
            id:       e['id'],
            taskName: e['task_name'],
            qty:      e['qty'].toString(),
            timing:   e['timing'],
          )).toList();
          _loading = false;
        });
      } else {
        setState(() { _loadError = 'Server returned ${response.statusCode}'; _loading = false; });
      }
    } catch (e) {
      setState(() { _loadError = 'Cannot connect to server'; _loading = false; });
    }
  }

  // ── API: CREATE entry ─────────────────────────────────────────────────────────
  Future<void> _createEntry(String taskName, String qty, String timing) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/timings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'taskName': taskName, 'qty': qty, 'timing': timing}),
      );
      if (response.statusCode == 201) {
        await _fetchEntries();
      } else {
        final body = jsonDecode(response.body);
        _showSnack(body['message'] ?? 'Failed to create entry');
      }
    } catch (e) {
      _showSnack('Cannot connect to server');
    }
  }

  // ── API: UPDATE entry ─────────────────────────────────────────────────────────
  Future<void> _updateEntry(int id, String taskName, String qty, String timing) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/timings/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'taskName': taskName, 'qty': qty, 'timing': timing}),
      );
      if (response.statusCode == 200) {
        await _fetchEntries();
      } else {
        final body = jsonDecode(response.body);
        _showSnack(body['message'] ?? 'Failed to update entry');
      }
    } catch (e) {
      _showSnack('Cannot connect to server');
    }
  }

  // ── API: DELETE entry ─────────────────────────────────────────────────────────
  Future<void> _deleteEntryApi(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/timings/$id'));
      if (response.statusCode == 200) {
        await _fetchEntries();
        _showSnack('Entry deleted', success: true);
      } else {
        _showSnack('Failed to delete entry');
      }
    } catch (e) {
      _showSnack('Cannot connect to server');
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? const Color(0xFF16A34A) : Colors.redAccent,
    ));
  }

  // ── Form helpers ──────────────────────────────────────────────────────────────

  void _clearForm() {
    setState(() {
      _selectedTaskName = null;
      _otherTaskCtrl.clear();
      _qtyCtrl.clear();
      _timingValCtrl.clear();
      _selectedTimingUnit = 'mins';
      _editingId = null;
    });
  }

  void _populateForm(_TaskEntry entry) {
    setState(() {
      _editingId        = entry.id;
      _qtyCtrl.text    = entry.qty;

      if (_taskOptions.contains(entry.taskName)) {
        _selectedTaskName = entry.taskName;
        _otherTaskCtrl.clear();
      } else {
        _selectedTaskName = 'Other';
        _otherTaskCtrl.text = entry.taskName;
      }

      final parts = entry.timing.split(' ');
      if (parts.length >= 2) {
        _timingValCtrl.text = parts[0];
        _selectedTimingUnit = _unitOptions.contains(parts[1]) ? parts[1] : 'mins';
      } else {
        _timingValCtrl.text = entry.timing.replaceAll(RegExp(r'[^0-9]'), '');
        _selectedTimingUnit = 'mins';
      }
    });
  }

  Future<void> _saveForm() async {
    String task = _selectedTaskName ?? '';
    if (task == 'Other') {
      task = _otherTaskCtrl.text.trim();
    }

    final qty    = _qtyCtrl.text.trim();
    final timingVal = _timingValCtrl.text.trim();
    final timingMerged = "$timingVal $_selectedTimingUnit";

    if (task.isEmpty || qty.isEmpty || timingVal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _saving = true);

    if (_editingId != null) {
      // ── UPDATE existing entry via API ───────────────────────────────────────
      await _updateEntry(_editingId!, task, qty, timingMerged);
    } else {
      // ── CREATE new entry via API ────────────────────────────────────────────
      await _createEntry(task, qty, timingMerged);
    }

    setState(() => _saving = false);
    _clearForm();
  }

  void _deleteEntry(int id) {
    if (_editingId == id) _clearForm();
    _deleteEntryApi(id); // ← API DELETE call
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: 'Time Manager',
      currentRoute: '/time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Management',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Efficiently organize tasks, schedules, and deadlines to maximize productivity.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Split Pane Workspace Grid ──
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildTable()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildFormPanel()),
                ],
              );
            }

            return Column(
              children: [
                _buildFormPanel(),
                const SizedBox(height: 24),
                _buildTable(),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── LEFT: Data log table ──
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Log',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: _fetchEntries,
                    child: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF1A3A8F)),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
            child: Row(
              children: const [
                _TH('NO.',     flex: 1),
                _TH('TASK',    flex: 3),
                _TH('QTY',     flex: 2),
                _TH('TIMING',  flex: 2),
                _TH('ACTIONS', flex: 2),
              ],
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF1A3A8F))),
            )
          else if (_loadError != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(children: [
                  Text(_loadError!, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fetchEntries,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3A8F)),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ]),
              ),
            )
          else if (_entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No tasks yet. Use the form to add one.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              ),
            )
          else
            Column(
              children: _entries.asMap().entries.map((e) {
                final idx   = e.key;
                final entry = e.value;
                final isEditing = _editingId == entry.id;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isEditing ? const Color(0xFFF0F4FF) : Colors.white,
                    border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text('${idx + 1}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.taskName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(entry.qty, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              entry.timing,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            _ActionBtn(
                              icon: Icons.edit_outlined,
                              color: const Color(0xFF2A52BE),
                              bg: const Color(0xFFEFF6FF),
                              onTap: () => _populateForm(entry),
                            ),
                            const SizedBox(width: 8),
                            _ActionBtn(
                              icon: Icons.delete_outline,
                              color: const Color(0xFFDC2626),
                              bg: const Color(0xFFFEE2E2),
                              onTap: () => _deleteEntry(entry.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ── RIGHT: Form editor panel ──
  Widget _buildFormPanel() {
    final isEditing = _editingId != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: const Color(0xFF1A3A8F),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                    color: Colors.white, size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'Edit Task Timing' : 'Set Timing',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                const SizedBox(height: 6),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTaskName,
                      isExpanded: true,
                      hint: const Text('Select task', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      items: _taskOptions.map((t) {
                        // ── A task name is "used" if it already exists in another row ──
                        // "Other" is always selectable; the row currently being edited
                        // keeps its own task name selectable too.
                        final isUsed = t != 'Other' &&
                            _entries.any((e) => e.taskName == t && e.id != _editingId);

                        return DropdownMenuItem(
                          value: t,
                          enabled: !isUsed, // ✅ shown, but cannot be picked if already added
                          child: Text(
                            isUsed ? '$t (already added)' : t,
                            style: TextStyle(
                              fontSize: 13,
                              color: isUsed ? const Color(0xFFB0B7C3) : const Color(0xFF1A1A2E),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTaskName = val),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
                    ),
                  ),
                ),

                // ── DYNAMIC RENDERING BLOCK FOR CUSTOM "OTHER" TASK ENTRY INPUT ──
                if (_selectedTaskName == "Other") ...[
                  const SizedBox(height: 14),
                  _buildInlineFormInputField(
                    label: 'Specify Custom Task Name *',
                    controller: _otherTaskCtrl,
                    hint: 'Enter your custom task name...',
                  ),
                ],

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInlineFormInputField(
                        label: 'Qty',
                        controller: _qtyCtrl,
                        hint: '1',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // ── TWO-SEGMENT TIMING FIELD MATRIX ──
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Timing *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 38,
                                  child: TextField(
                                    controller: _timingValCtrl,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
                                    decoration: InputDecoration(
                                      hintText: '30',
                                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(color: Color(0xFF1A3A8F), width: 1.5)
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFD1D5DB)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedTimingUnit,
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280), size: 16),
                                      items: _unitOptions.map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      )).toList(),
                                      onChanged: (val) => setState(() => _selectedTimingUnit = val!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _clearForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A8F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isEditing ? 'Update' : 'Create',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineFormInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF1A3A8F), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  final int flex;
  const _TH(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280), letterSpacing: 0.6)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}