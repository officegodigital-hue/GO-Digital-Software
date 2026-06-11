import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class TasksAssignScreen extends StatefulWidget {
  const TasksAssignScreen({super.key});

  @override
  State<TasksAssignScreen> createState() => _TasksAssignScreenState();
}

class _TasksAssignScreenState extends State<TasksAssignScreen> {
  // Sample Data matching your exact row setup
  final List<Map<String, dynamic>> taskRows = [
    {
      "client": "GA MALL",
      "deliverables": "DELIVERABLES",
      "adsHandling": "PAVI",
      "adsPlatform": "ADS",
      "pageHandling": "PAGE HANDLING",
      "pagesPlatform": "PAGES",
      "designer": "PAVI",
      "designerTasks": "WEBSITE",
      "videographer": "PAVI",
      "videographerTasks": "WEBSITE",
      "uiUxDesigner": "PAVI",
      "uiUxTasks": "WEBSITE",
      "deadline": "1 MONTH",
      "comments": "",
      "isAssigned": true,
    },
    {
      "client": "JYOTHI",
      "deliverables": "DELIVERABLES",
      "adsHandling": "ADS HANDLING",
      "adsPlatform": "ADS",
      "pageHandling": "PAGE HANDLING",
      "pagesPlatform": "PAGES",
      "designer": "DESIGNER",
      "designerTasks": "DESIGNS",
      "videographer": "DESIGNER",
      "videographerTasks": "DESIGNS",
      "uiUxDesigner": "DESIGNER",
      "uiUxTasks": "DESIGNS",
      "deadline": "DEADLINE",
      "comments": "",
      "isAssigned": false,
    },
    {
      "client": "BRAHMOS",
      "deliverables": "DELIVERABLES",
      "adsHandling": "ADS HANDLING",
      "adsPlatform": "ADS",
      "pageHandling": "PAGE HANDLING",
      "pagesPlatform": "PAGES",
      "designer": "DESIGNER",
      "designerTasks": "DESIGNS",
      "videographer": "DESIGNER",
      "videographerTasks": "DESIGNS",
      "uiUxDesigner": "DESIGNER",
      "uiUxTasks": "DESIGNS",
      "deadline": "DEADLINE",
      "comments": "",
      "isAssigned": false,
    },
    {
      "client": "KALPAKA",
      "deliverables": "DELIVERABLES",
      "adsHandling": "ADS HANDLING",
      "adsPlatform": "ADS",
      "pageHandling": "PAGE HANDLING",
      "pagesPlatform": "PAGES",
      "designer": "DESIGNER",
      "designerTasks": "DESIGNS",
      "videographer": "DESIGNER",
      "videographerTasks": "DESIGNS",
      "uiUxDesigner": "DESIGNER",
      "uiUxTasks": "DESIGNS",
      "deadline": "DEADLINE",
      "comments": "",
      "isAssigned": false,
    },
  ];

void _addRow() {
  setState(() {
    taskRows.add({
      "client": "CLIENT NAME",
      "deliverables": "DELIVERABLES",
      "adsHandling": "ADS HANDLING",
      "adsPlatform": "ADS",
      "pageHandling": "PAGE HANDLING",
      "pagesPlatform": "PAGES",
      "designer": "DESIGNER",
      "designerTasks": "DESIGNS",
      "videographer": "DESIGNER",
      "videographerTasks": "DESIGNS",
      "uiUxDesigner": "DESIGNER",
      "uiUxTasks": "DESIGNS",
      "deadline": "DEADLINE",
      "comments": "",
      "isAssigned": false,
    });
  });
}
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Tasks Assign",
      currentRoute: "/tasks",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title & Action Header Toolbar Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Task Assign - Employees",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Assign, monitor, and manage employee tasks based on departments, projects, and client deliverables.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  elevation: 0,
                ),
                label: const Text("Add Section", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Scrollable Table Box (Wrapped in SingleChildScrollView for accurate sizing) ──
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              height: 500, // Fixed layout height prevents zero-collapsing on Dashboard screens
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Fixed Column Panel: Client Name
                    Container(
                      width: 180,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 48,
                            color: const Color(0xFF0052CC),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: const Text("CLIENT NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                          ),
                          ...taskRows.map((row) => _buildFixedClientCell(row["client"])),
                          ...List.generate(4, (_) => _buildFixedClientCell("")),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),

                    // Horizontally Scrollable Data Fields Layout
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 2200, // Provides plenty of workspace width for matrix headers
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Scrollable Header Row
                              Container(
                                height: 48,
                                color: const Color(0xFFF8FAFC),
                                child: Row(
                                  children: const [
                                    _HeaderCell(width: 160, label: "DELIVERABLES"),
                                    _HeaderCell(width: 160, label: "ADS HANDLING"),
                                    _HeaderCell(width: 160, label: "ADS PLATFORM"),
                                    _HeaderCell(width: 160, label: "PAGE HANDLING"),
                                    _HeaderCell(width: 160, label: "PAGES PLATFORM"),
                                    _HeaderCell(width: 160, label: "DESIGNER"),
                                    _HeaderCell(width: 140, label: "TASKS"),
                                    _HeaderCell(width: 160, label: "VIDEOGRAPHER"),
                                    _HeaderCell(width: 140, label: "TASKS"),
                                    _HeaderCell(width: 160, label: "UI / UX DESIGNER"),
                                    _HeaderCell(width: 140, label: "TASKS"),
                                    _HeaderCell(width: 160, label: "DEADLINE"),
                                    _HeaderCell(width: 180, label: "COMMENTS"),
                                    _HeaderCell(width: 150, label: "ACTION"),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),

                              // Active Data Grid Rows
                              ...taskRows.asMap().entries.map((entry) {
                                return _buildScrollableTableRow(entry.value, entry.key);
                              }),

                              // Empty Ledger Placeholder Data Rows Layout
                              ...List.generate(4, (_) => _buildEmptyPlaceholderTableRow()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedClientCell(String clientName) {
    bool isEmpty = clientName.isEmpty;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0052CC), 
        border: Border(bottom: BorderSide(color: Color(0xFF0044B3), width: 1)),
      ),
      alignment: Alignment.centerLeft,
      child: isEmpty 
          ? null 
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(clientName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
              ],
            ),
    );
  }

  Widget _buildScrollableTableRow(Map<String, dynamic> row, int index) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          _buildDropdownCell(160, row["deliverables"], ["DELIVERABLES"]),
          _buildDropdownCell(160, row["adsHandling"], ["PAVI", "ADS HANDLING"]),
          _buildDropdownCell(160, row["adsPlatform"], ["ADS"]),
          _buildDropdownCell(160, row["pageHandling"], ["PAGE HANDLING"]),
          _buildDropdownCell(160, row["pagesPlatform"], ["PAGES"]),
          _buildDropdownCell(160, row["designer"], ["PAVI", "DESIGNER"]),
          _buildDropdownCell(140, row["designerTasks"], ["WEBSITE", "DESIGNS"]),
          _buildDropdownCell(160, row["videographer"], ["PAVI", "DESIGNER"]),
          _buildDropdownCell(140, row["videographerTasks"], ["WEBSITE", "DESIGNS"]),
          _buildDropdownCell(160, row["uiUxDesigner"], ["PAVI", "DESIGNER"]),
          _buildDropdownCell(140, row["uiUxTasks"], ["WEBSITE", "DESIGNS"]),
          _buildDropdownCell(160, row["deadline"], ["1 MONTH", "DEADLINE"]),
          
          // Comments Cell
          Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))),
            alignment: Alignment.center,
            child: SizedBox(
              height: 32,
              child: TextField(
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  fillColor: const Color(0xFFF8FAFC),
                  filled: true,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0052CC))),
                ),
              ),
            ),
          ),

          // Action Button Cell
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    row["isAssigned"] = !row["isAssigned"];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: row["isAssigned"] ? const Color(0xFF00C853) : const Color(0xFFE2E8F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  row["isAssigned"] ? "ASSIGNED" : "ASSIGN",
                  style: TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.w800, 
                    color: row["isAssigned"] ? Colors.white : const Color(0xFF94A3B8),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholderTableRow() {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: List.generate(
          14, 
          (index) => Container(
            width: [160, 160, 160, 160, 160, 160, 140, 160, 140, 160, 140, 160, 180, 150][index].toDouble(),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCell(double width, String currentValue, List<String> dropdownItems) {
    String valueInList = dropdownItems.contains(currentValue) ? currentValue : dropdownItems.first;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      alignment: Alignment.centerLeft,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valueInList,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: dropdownItems.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: (newValue) {},
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final double width;
  final String label;

  const _HeaderCell({required this.width, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5),
      ),
    );
  }

  
}