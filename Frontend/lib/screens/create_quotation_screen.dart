import 'package:flutter/material.dart';
import '../layouts/admin_layout.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({super.key});

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final quotationNoController = TextEditingController(text: "QT-2024-089");
  final clientNameController = TextEditingController(text: "GA MALL");
  final dateController = TextEditingController(text: "05/20/2026");
  final expiryController = TextEditingController(text: "05/25/2026");

  final qtyController = TextEditingController(text: "1");
  final rateController = TextEditingController(text: "8,000.00");
  final paidAmountController = TextEditingController(text: "0.00");

  String selectedDeliverable = 'DELIVERABLES';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Create Quotation",
      currentRoute: "/quotation", // Maintains sidebar tab highlight state
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Toolbar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Create Quotation",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text("Discard", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text("Save Quotation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Meta Form Fields Ribbon Box ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildInlineFormInput("Quotation No", quotationNoController, readOnly: true, fillColor: const Color(0xFFEFF6FF))),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineFormInput("Client Name", clientNameController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineFormInput("Quotation Date", dateController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineFormInput("Expire Date", expiryController)), // Preserved typo label from image
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Line Items Invoicing Data Grid ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Inner Table Structural Column Titles
                Container(
                  color: const Color(0xFFEAEFF8),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      SizedBox(width: 40, child: Text("S.No", style: _tableLabelStyle)),
                      Expanded(flex: 5, child: Text("Description", style: _tableLabelStyle)),
                      SizedBox(width: 80, child: Text("QTY", style: _tableLabelStyle)),
                      SizedBox(width: 120, child: Text("Rate", style: _tableHeaderStyleRight)),
                      SizedBox(width: 140, child: Text("Amount", style: _tableHeaderStyleRight)),
                      SizedBox(width: 40, child: Text("", style: _tableLabelStyle)),
                    ],
                  ),
                ),

                // Table Input Row Content Item
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      const SizedBox(width: 40, child: Text("01", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
                      Expanded(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildInnerDropdownField(),
                        ),
                      ),
                      SizedBox(width: 80, child: _buildInnerNumInput(qtyController, textAlign: TextAlign.center)),
                      const SizedBox(width: 12),
                      SizedBox(width: 120, child: _buildInnerNumInput(rateController, textAlign: TextAlign.right)),
                      const SizedBox(width: 20),
                      const SizedBox(
                        width: 120,
                        child: Text("₹8,000.00", textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ),
                      SizedBox(
                        width: 40,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Link Button
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF0052CC)),
                SizedBox(width: 6),
                Text("Add Section", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0052CC))),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Accounting Totals Card Panel ──
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSummaryLineItem("Subtotal", "₹8,000.00"),
                  const SizedBox(height: 14),
                  _buildSummaryLineItem("Tax (0%)", "₹0.00"),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                  _buildSummaryLineItem("Total Amount", "₹8,000.00", isBoldText: true, highlightColor: const Color(0xFF0052CC)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Paid Amount", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      SizedBox(
                        width: 100,
                        height: 36,
                        child: TextField(
                          controller: paidAmountController,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            prefixText: "₹ ",
                            prefixStyle: TextStyle(color: Color(0xFF475569), fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0052CC))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                  _buildSummaryLineItem("Balance Amount", "₹8,000.00", isBoldText: true, useFillBanner: true),
                  const SizedBox(height: 24),
                  
                  // Primary PDF Dispatch Button Component
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.assignment_turned_in_rounded, size: 16, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      label: const Text("Save & Generate Quotation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "A PDF copy will be generated and sent\nto the client.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── CORE UTILITY SUB-WIDGET COMPONENTS ──
  Widget _buildInlineFormInput(String label, TextEditingController controller, {bool readOnly = false, Color? fillColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              filled: fillColor != null,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInnerDropdownField() {
    return Container(
      height: 38,
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDeliverable,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          items: const [
            DropdownMenuItem(value: 'DELIVERABLES', child: Text("DELIVERABLES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
          ],
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildInnerNumInput(TextEditingController controller, {required TextAlign textAlign}) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
        ),
      ),
    );
  }

  Widget _buildSummaryLineItem(String label, String value, {bool isBoldText = false, Color? highlightColor, bool useFillBanner = false}) {
    final textStyle = TextStyle(
      fontSize: isBoldText ? 14 : 13,
      fontWeight: isBoldText ? FontWeight.w800 : FontWeight.w500,
      color: highlightColor ?? (isBoldText ? const Color(0xFF0F172A) : const Color(0xFF475569)),
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );

    if (useFillBanner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFDCE4F7), borderRadius: BorderRadius.circular(4)),
        child: content,
      );
    }
    return content;
  }

  static const TextStyle _tableLabelStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569));
  static const TextStyle _tableHeaderStyleRight = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569));
}