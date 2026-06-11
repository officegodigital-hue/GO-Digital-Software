import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have intl added to pubspec.yaml for date formatting
import '../layouts/admin_layout.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart'; 

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final invoiceNoController = TextEditingController(text: "INV-2023-0842");
  final dateController = TextEditingController();
  final maintenanceDateController = TextEditingController(text: "dd/MM/yyyy");

  // Inline row input controllers
  final inlineClientNameController = TextEditingController(text: "GA MALL");
  final inlinePackageController = TextEditingController(text: "Smart Package");
  final qtyController = TextEditingController(text: "1");
  final rateController = TextEditingController(text: "12,000.00"); 
  final inlinePaidController = TextEditingController(text: "6,000.00");

  final paidAmountController = TextEditingController(text: "6,000.00"); 
  final discountController = TextEditingController(text: "0.00");
  final notesController = TextEditingController();

 
  String selectedPackage = 'Smart Package'; 
  bool agreedToTerms = false;
  bool includeGST = true;

  final Map<String, double> packageRates = {
    'Kickstart Package': 8000.00,
    'Smart Package': 12000.00,
    'Performance Package': 15000.00,
  };

  @override
  void initState() {
    super.initState();
    // Automatically sets the Date field to show today's calendar date upon initialization
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }


// ── ADD these imports at the top of add_invoice_screen.dart ───────────────────
// import 'package:flutter/services.dart'; // for rootBundle

// ── REPLACE your entire _printInvoice method with this ───────────────────────

Future<void> _printInvoice(double total, double paid, double balance) async {

  // ── Load assets ─────────────────────────────────────────────────────────────
  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/godigital_logo.png'))
        .buffer.asUint8List(),
  );
  final sealImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/office_seal.png'))
        .buffer.asUint8List(),
  );

  // ── Load fonts ───────────────────────────────────────────────────────────────
  final font      = await PdfGoogleFonts.notoSansRegular();
  final fontBold  = await PdfGoogleFonts.notoSansBold();

  final pdf = pw.Document();

  // ── Colors ───────────────────────────────────────────────────────────────────
  const PdfColor blue   = PdfColor.fromInt(0xFF0052CC);
  const PdfColor white  = PdfColor.fromInt(0xFFFFFFFF);
  const PdfColor grey   = PdfColor.fromInt(0xFFF0F0F0);
  const PdfColor bdrClr = PdfColor.fromInt(0xFF888888);

  // ── Rupee formatter ──────────────────────────────────────────────────────────
  String fmt(double v) => '\u20B9 ${v.toStringAsFixed(0)} /-';

  // ── Parse form values ────────────────────────────────────────────────────────
  final double rate   = double.tryParse(rateController.text.replaceAll(',', '')) ?? 0;
  final int    qty    = int.tryParse(qtyController.text) ?? 1;
  final double amount = rate * qty;

  // ── Reusable table cell ──────────────────────────────────────────────────────
  pw.Widget cell(
    String text, {
    bool bold          = false,
    double size        = 9,
    pw.Alignment align = pw.Alignment.centerLeft,
    double padH        = 6,
    double padV        = 6,
    PdfColor? bg,
    PdfColor color     = PdfColors.black,
  }) {
    return pw.Container(
      color: bg,
      padding: pw.EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: bold ? fontBold : font,
          fontSize: size,
          color: color,
        ),
      ),
    );
  }

  // ── Summary row (TOTAL / PAID / BALANCE) ─────────────────────────────────────
  pw.TableRow summaryRow(String label, double value) {
    return pw.TableRow(
      children: [
        pw.Container(
          height: 26,
          decoration: pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(color: bdrClr, width: 0.5)),
          ),
        ),
        pw.Container(
          height: 26,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          alignment: pw.Alignment.center,
          child: pw.Text(label,
              style: pw.TextStyle(font: fontBold, fontSize: 9)),
        ),
        pw.Container(
          height: 26,
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: bdrClr, width: 0.5)),
          ),
        ),
        pw.Container(
          height: 26,
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: bdrClr, width: 0.5)),
          ),
        ),
        pw.Container(
          height: 26,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          alignment: pw.Alignment.centerRight,
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: bdrClr, width: 0.5)),
          ),
          child: pw.Text(fmt(value),
              style: pw.TextStyle(font: fontBold, fontSize: 9)),
        ),
      ],
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [

            // ── TOP BLUE BAR ────────────────────────────────────────────────
            pw.Container(
              color: blue,
              height: 28,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: List.generate(
                  4,
                  (_) => pw.Container(
                    width: 10, height: 10,
                    margin: const pw.EdgeInsets.only(left: 5),
                    color: white,
                  ),
                ),
              ),
            ),

            // ── MAIN BODY ───────────────────────────────────────────────────
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(32, 18, 32, 18),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // Logo
                    pw.Container(
                      width: 140, height: 55,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),

                    pw.SizedBox(height: 18),

                    // ── HEADER TABLE ──────────────────────────────────────
                    pw.Table(
                      border: pw.TableBorder.all(color: bdrClr, width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(4),
                        1: const pw.FixedColumnWidth(105),
                        2: const pw.FixedColumnWidth(105),
                      },
                      children: [
                        pw.TableRow(children: [
                          pw.Container(
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(vertical: 12),
                            child: pw.Text('GO DIGITAL',
                                style: pw.TextStyle(font: fontBold, fontSize: 12)),
                          ),
                          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                            cell('Invoice No.', bold: true, size: 8, padV: 5),
                            cell(invoiceNoController.text, size: 9, padV: 3),
                          ]),
                          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                            cell('Invoice Date', bold: true, size: 8, padV: 5),
                            cell(dateController.text, size: 9, padV: 3),
                          ]),
                        ]),
                      ],
                    ),

                    // ── TO ROW ────────────────────────────────────────────
                    pw.Table(
                      border: pw.TableBorder.all(color: bdrClr, width: 0.5),
                      children: [
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('TO',
                                    style: pw.TextStyle(font: fontBold, fontSize: 9)),
                                pw.SizedBox(height: 3),
                                pw.Text(inlineClientNameController.text,
                                    style: pw.TextStyle(font: font, fontSize: 9)),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ),

                    pw.SizedBox(height: 4),

                    // ── ITEMS TABLE ───────────────────────────────────────
                    pw.Table(
                      border: pw.TableBorder.all(color: bdrClr, width: 0.5),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(34),
                        1: const pw.FlexColumnWidth(3),
                        2: const pw.FixedColumnWidth(44),
                        3: const pw.FixedColumnWidth(64),
                        4: const pw.FixedColumnWidth(70),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: grey),
                          children: [
                            cell('S No',         bold: true, align: pw.Alignment.center),
                            cell('DESCRIPTIONS', bold: true, align: pw.Alignment.center),
                            cell('QTY',          bold: true, align: pw.Alignment.center),
                            cell('RATE',         bold: true, align: pw.Alignment.center),
                            cell('AMOUNT',       bold: true, align: pw.Alignment.center),
                          ],
                        ),
                        pw.TableRow(children: [
                          cell('1', align: pw.Alignment.center),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(7),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(selectedPackage,
                                    style: pw.TextStyle(font: fontBold, fontSize: 9)),
                                pw.SizedBox(height: 3),
                                pw.Text('\u2022 domain',
                                    style: pw.TextStyle(font: font, fontSize: 8)),
                                pw.Text('\u2022 hosting',
                                    style: pw.TextStyle(font: font, fontSize: 8)),
                              ],
                            ),
                          ),
                          cell(qty.toString(), align: pw.Alignment.center),
                          cell(rate.toStringAsFixed(0), align: pw.Alignment.centerRight),
                          cell(amount.toStringAsFixed(0), align: pw.Alignment.centerRight),
                        ]),
                        summaryRow('TOTAL AMOUNT',       total),
                        summaryRow('PAID AMOUNT',         paid),
                        summaryRow('BALANCE TO BE PAID',  balance),
                      ],
                    ),

                    pw.SizedBox(height: 18),

                    // ── NOTES ────────────────────────────────────────────
                    pw.Text('Notes',
                        style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      notesController.text.isEmpty ? ' ' : notesController.text,
                      style: pw.TextStyle(font: font, fontSize: 9),
                    ),

                    pw.SizedBox(height: 14),

                    // ── TERMS & CONDITIONS ────────────────────────────────
                    pw.Text('Terms & Conditions',
                        style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Text('\u2022 Project development only',
                        style: pw.TextStyle(font: font, fontSize: 9)),
                    pw.Text('\u2022 50% advance required',
                        style: pw.TextStyle(font: font, fontSize: 9)),
                    pw.Text('\u2022 No refund after approval',
                        style: pw.TextStyle(font: font, fontSize: 9)),

                    pw.Spacer(),

                    // ── BANK DETAILS + SEAL SIDE BY SIDE ─────────────────
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [

                        // LEFT — bank details
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'BANK ACCOUNT DETAILS',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 9,
                                  decoration: pw.TextDecoration.underline,
                                  color:PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'NAME: GO DIGITAL, BANK: IDFC FIRST BANK, A/C NO: 10075087276, BRANCH: KILPAUK, IFSC: IDFB0080121',
                                style: pw.TextStyle(
                                    font: fontBold, fontSize: 9, color: blue),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Office: +91 94449 43094 | Email: godigitalindaras@gmail.com | Website: www.godigital.ind.in',
                                style: pw.TextStyle(font: font, fontSize: 9),
                              ),
                            ],
                          ),
                        ),

                        pw.SizedBox(width: 16),

                        // RIGHT — seal image ← FIXED POSITION
                        pw.Container(
                          width: 75,
                          height: 75,
                          child: pw.Image(sealImage, fit: pw.BoxFit.contain),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── BOTTOM BLUE FOOTER BAR ────────────────────────────────────
            pw.Container(
              color: blue,
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'GO DIGITAL',
                      style: pw.TextStyle(font: fontBold, fontSize: 15, color: white),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Center(
                    child: pw.Text(
                      'No:14, Udaya Suriyan Nagar, Guduvanchery 603202 Near Olala Cafe',
                      style: pw.TextStyle(font: font, fontSize: 14, color: white),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
} 
 // Helper method to prompt the native calendar view dialog sheet
  Future<void> _selectCalendarDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    
    // Attempt to parse existing text inside the controller to focus calendar on that year/month
    try {
      if (controller.text.isNotEmpty && controller.text != "dd/MM/yyyy") {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      }
    } catch (_) {
      // Graceful fallback to present-day initialization if parsing criteria fails
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0052CC), // Matches app identity blue accent tone
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
        
      },
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── MATH RUNTIME DATA PROPAGATION ENGINE ──
    double baseRate = packageRates[selectedPackage] ?? 0.00;
    int qty = int.tryParse(qtyController.text) ?? 1;
    double calculatedRowAmount = baseRate * qty;

    double rowPaidAmount = double.tryParse(inlinePaidController.text.replaceAll(',', '')) ?? 0.00;
    double rowPendingAmount = calculatedRowAmount - rowPaidAmount;
    if (rowPendingAmount < 0) rowPendingAmount = 0;

    double discount = double.tryParse(discountController.text.replaceAll(',', '')) ?? 0.00;
    double taxableAmount = calculatedRowAmount - discount;
    if (taxableAmount < 0) taxableAmount = 0;

    double tax = includeGST ? (taxableAmount * 0.18) : 0.00;
    double totalAmount = taxableAmount + tax;

    double overallPaidAmount = double.tryParse(paidAmountController.text.replaceAll(',', '')) ?? 0.00;
    double overallBalanceAmount = totalAmount - overallPaidAmount;

    return AdminLayout(
      pageTitle: "Invoice",
      currentRoute: "/invoice",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Action Ribbon Toolbar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Add Invoice",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
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
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text("Save Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Meta Fields Ribbon Box (Equipped with Interactive Calendar Selectors) ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildInlineFormInput("Invoice No", invoiceNoController, readOnly: true, fillColor: const Color(0xFFEFF6FF))),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerFormInput("Date", dateController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineFormInput("Client Name", inlineClientNameController)),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerFormInput("Maintenance Date", maintenanceDateController)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Line Items Invoicing Custom Data Grid ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: const Color(0xFFEAEFF8),
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      SizedBox(width: 45, child: Text("S.No", style: _tableLabelStyle)),
                      Expanded(flex: 6, child: Text("Description (Packages)", style: _tableLabelStyle)),
                      SizedBox(width: 60, child: Text("QTY", textAlign: TextAlign.center, style: _tableLabelStyle)),
                      SizedBox(width: 100, child: Text("Rate", textAlign: TextAlign.right, style: _tableLabelStyle)),
                      SizedBox(width: 110, child: Text("Amount", textAlign: TextAlign.right, style: _tableLabelStyle)),
                      SizedBox(width: 120, child: Text("Paid Amount", textAlign: TextAlign.center, style: _tableLabelStyle)),
                      SizedBox(width: 130, child: Text("Pending Amount", textAlign: TextAlign.center, style: _tableLabelStyle)),
                      SizedBox(width: 30, child: Text("", style: _tableLabelStyle)),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      const SizedBox(width: 45, child: Text("01", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
                      
                      

                      Expanded(flex: 6, child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildInnerPackageDropdown(),
                      )),

                      SizedBox(width: 60, child: TextField(
                        controller: qtyController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
                        ),
                      )),
                      const SizedBox(width: 8),

                      SizedBox(width: 100, child: _buildInnerNumInput(rateController, textAlign: TextAlign.right)),
                      
                      SizedBox(
                        width: 110,
                        child: Text(
                          "₹${calculatedRowAmount.toStringAsFixed(2)}", 
                          textAlign: TextAlign.right, 
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                      ),

                      SizedBox(
                        width: 120,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: inlinePaidController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                            onChanged: (value) {
                              setState(() {
                                paidAmountController.text = value; 
                              });
                            },
                            decoration: const InputDecoration(
                              prefixText: "₹ ",
                              prefixStyle: TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 130,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "₹${rowPendingAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 30,
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

          const SizedBox(height: 24),

          // ── Two-Column Bottom Split Layout Layout ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Expanded(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const Text("Notes", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                          //       const SizedBox(height: 8),
                          //       TextField(
                          //         controller: notesController,
                          //         maxLines: 4,
                          //         decoration: InputDecoration(
                          //           hintText: "Enter internal notes or comments...",
                          //           hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          //           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                          //           focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0052CC))),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Terms & Conditions", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Standard payment terms apply: Net 30. Please include invoice number on all wire transfers.",
                                    style: TextStyle(fontSize: 14, color: Color(0xFF1E40AF), height: 1.4, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: agreedToTerms,
                                        onChanged: (val) => setState(() => agreedToTerms = val!),
                                        activeColor: const Color(0xFF0052CC),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("Agree to defined terms", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("BANK DETAILS (DISPLAY)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBankItem("Name", "MarqueMetrics\nLLC"),
                              _buildBankItem("Bank", "First National\nBank"),
                              _buildBankItem("A/C Number", "**** **** 8291"),
                              _buildBankItem("IFSC / Routing", "FNBBUS33"),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),

              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow("Subtotal", "₹${calculatedRowAmount.toStringAsFixed(2)}"),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Discount", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: TextField(
                              controller: discountController,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              onChanged: (value) => setState(() {}),
                              decoration: const InputDecoration(
                                prefixText: "₹ ",
                                prefixStyle: TextStyle(color: Color(0xFF475569), fontSize: 15),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0052CC))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Include 18% GST", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          Switch(
                            value: includeGST,
                            // activeColor: const Color(0xFF0052CC),
                            activeTrackColor: const Color(0xFF0052CC),
                            onChanged: (bool value) {
                              setState(() {
                                includeGST = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildSummaryRow(
                        "Tax (18% GST)", 
                        "₹${tax.toStringAsFixed(2)}",
                        textColor: includeGST ? const Color(0xFF0F172A) : Colors.grey,
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                      _buildSummaryRow("Total Amount", "₹${totalAmount.toStringAsFixed(2)}", isBold: true, textColor: const Color(0xFF0052CC)),
                      const SizedBox(height: 14),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Paid Amount", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: TextField(
                              controller: paidAmountController,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              onChanged: (value) {
                                setState(() {
                                  inlinePaidController.text = value; 
                                });
                              },
                              decoration: const InputDecoration(
                                prefixText: "₹ ",
                                prefixStyle: TextStyle(color: Color(0xFF475569), fontSize: 15),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0052CC))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                      _buildSummaryRow("Balance Amount", "₹${overallBalanceAmount.toStringAsFixed(2)}", isBold: true, isBanner: true),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        // child: ElevatedButton.icon(
                        //   onPressed: () => Navigator.pop(context),
                        //   icon: const Icon(Icons.description_rounded, size: 16, color: Colors.white),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: const Color(0xFF0052CC),
                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        //     padding: const EdgeInsets.symmetric(vertical: 16),
                        //     elevation: 0,
                        //   ),
                        //   label: const Text("Save & Generate Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        // ),
                        child: ElevatedButton.icon(
              onPressed: () async {
                await _printInvoice(totalAmount, overallPaidAmount, overallBalanceAmount);
                if (!mounted) return;
                Navigator.pop(context);
              },
              icon: const Icon(Icons.print, size: 16, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052CC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              label: const Text("Save & Print Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "A PDF copy will be generated and sent\nto the client.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Input constructor wrapping interactive calendar callback events
  Widget _buildDatePickerFormInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            readOnly: true, // Prevents custom raw keyboard typing block strings
            onTap: () => _selectCalendarDate(context, controller),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineFormInput(String label, TextEditingController controller, {bool readOnly = false, Color? fillColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
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

  Widget _buildGridInputField(TextEditingController controller) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
        ),
      ),
    );
  }

  Widget _buildInnerPackageDropdown() {
    return Container(
      height: 36,
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPackage,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          items: packageRates.keys.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedPackage = val!;
              inlinePackageController.text = val; 
              rateController.text = (packageRates[val] ?? 0.00).toStringAsFixed(2); 
            });
          },
        ),
      ),
    );
  }

  Widget _buildInnerNumInput(TextEditingController controller, {required TextAlign textAlign}) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        readOnly: true, 
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
        ),
      ),
    );
  }

  Widget _buildBankItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8A94A6))),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), height: 1.3)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String val, {bool isBold = false, Color? textColor, bool isBanner = false}) {
    final style = TextStyle(
      fontSize: isBold ? 15 : 14,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
      color: textColor ?? (isBold ? const Color(0xFF0F172A) : const Color(0xFF475569)),
    );

    final innerContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(val, style: style)],
    );

    if (isBanner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFDCE4F7), borderRadius: BorderRadius.circular(4)),
        child: innerContent,
      );
    }
    return innerContent;
  }

  static const TextStyle _tableLabelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569));
}