import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../layouts/admin_layout.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

// ── One line-item row in the quotation table ────────────────────────────────────
// isPackageRow = true  → first row, description comes from a Package dropdown
//                         (rate auto-fills from the selected package's price)
// isPackageRow = false → "Add Section" rows, description is free text,
//                         rate is editable manually
class _QuotationItemRow {
  int? packageId;
  bool isPackageRow;
  final TextEditingController descriptionCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController paidCtrl;

  _QuotationItemRow({
    this.packageId,
    required this.isPackageRow,
    String description = '',
    String qty = '1',
    String rate = '0.00',
    String paid = '0.00',
  })  : descriptionCtrl = TextEditingController(text: description),
        qtyCtrl = TextEditingController(text: qty),
        rateCtrl = TextEditingController(text: rate),
        paidCtrl = TextEditingController(text: paid);

  void dispose() {
    descriptionCtrl.dispose();
    qtyCtrl.dispose();
    rateCtrl.dispose();
    paidCtrl.dispose();
  }
}

class CreateQuotationScreen extends StatefulWidget {
  final int? quotationId;
  final bool viewOnly;

  const CreateQuotationScreen({super.key, this.quotationId, this.viewOnly = false});

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  // ── API base URL ──────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://localhost:3000/api';

  final quotationNoController = TextEditingController(text: "Loading...");
  final clientNameController = TextEditingController(text: "GA MALL");
  final dateController = TextEditingController();
  final expiryController = TextEditingController();

  bool includeGST = false;
  bool _isSaving = false;
  bool _isPrinting = false;

  // ── Edit / View mode state ────────────────────────────────────────────────────
  int? _quotationId;     // null = creating a new quotation
  bool _viewOnly = false; // true = read-only "View" mode
  bool _loadingExisting = false;
  bool _argsProcessed = false;

  // ── Packages fetched from backend, used to populate the deliverable dropdown ──
  List<Map<String, dynamic>> _packages = [];
  bool _loadingPackages = true;

  // ── Line items — starts with one package-driven row ──────────────────────────
  late List<_QuotationItemRow> _items;

  @override
  void initState() {
    super.initState();
    _items = [_QuotationItemRow(isPackageRow: true)];
    // ── Default dates in dd/MM/yyyy format ──────────────────────────────────
    final now = DateTime.now();
    dateController.text = DateFormat('dd/MM/yyyy').format(now);
    expiryController.text = DateFormat('dd/MM/yyyy').format(now.add(const Duration(days: 5)));
    _fetchPackages();

    // ── Use constructor-provided quotationId/viewOnly if given directly ──────
    _quotationId = widget.quotationId;
    _viewOnly = widget.viewOnly;
    if (_quotationId != null) {
      _loadExistingQuotation(_quotationId!);
    } else {
      _fetchNextQuotationNumber();
    }
  }

  // ── Also support passing { quotationId, viewOnly } via Navigator arguments ──
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsProcessed) return;
    _argsProcessed = true;

    if (widget.quotationId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final id = args['quotationId'];
        final view = args['viewOnly'] == true;
        if (id is int) {
          setState(() {
            _quotationId = id;
            _viewOnly = view;
          });
          _loadExistingQuotation(id);
        }
      }
    }
  }

  // ── Load an existing quotation (for View / Edit) ─────────────────────────────
  Future<void> _loadExistingQuotation(int id) async {
    setState(() => _loadingExisting = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/quotations/$id'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        // Dispose default rows before replacing
        for (final item in _items) {
          item.dispose();
        }

        final List<_QuotationItemRow> loadedItems = [];
        for (final it in (data['items'] as List)) {
          loadedItems.add(_QuotationItemRow(
            isPackageRow: it['package_id'] != null,
            packageId: it['package_id'],
            description: it['description'] ?? '',
            qty: (it['qty'] ?? 1).toString(),
            rate: double.tryParse(it['rate'].toString())?.toStringAsFixed(2) ?? '0.00',
            paid: double.tryParse(it['paid_amount'].toString())?.toStringAsFixed(2) ?? '0.00',
          ));
        }

        setState(() {
          quotationNoController.text = data['quotation_no'] ?? '';
          clientNameController.text = data['client_name'] ?? '';
          dateController.text = data['quotation_date'] ?? '';
          expiryController.text = data['expiry_date'] ?? '';
          includeGST = data['include_gst'] == 1 || data['include_gst'] == true;
          _items = loadedItems.isNotEmpty ? loadedItems : [_QuotationItemRow(isPackageRow: true)];
          _loadingExisting = false;
        });
      } else {
        setState(() => _loadingExisting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to load quotation'),
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    } catch (e) {
      setState(() => _loadingExisting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot connect to server'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  // ── Helper to prompt the native calendar view dialog sheet (dd/MM/yyyy) ─────
  Future<void> _selectCalendarDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      }
    } catch (_) {
      // Graceful fallback to present-day initialization if parsing fails
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
              primary: Color(0xFF0052CC),
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
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    quotationNoController.dispose();
    clientNameController.dispose();
    dateController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  // ── FETCH packages list for the deliverable dropdown ─────────────────────────
  Future<void> _fetchPackages() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/packages'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _packages = List<Map<String, dynamic>>.from(body['data']);
          _loadingPackages = false;
        });
      } else {
        setState(() => _loadingPackages = false);
      }
    } catch (e) {
      setState(() => _loadingPackages = false);
    }
  }

  // ── FETCH next auto-generated quotation number ───────────────────────────────
  Future<void> _fetchNextQuotationNumber() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/quotations/next-number'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          quotationNoController.text = body['data']['quotationNo'];
        });
      } else {
        setState(() => quotationNoController.text = "QT-2026-089");
      }
    } catch (e) {
      setState(() => quotationNoController.text = "QT-2026-089");
    }
  }

  // ── Helper: parse "12,000.00" style strings ──────────────────────────────────
  double _parseAmount(String text) => double.tryParse(text.replaceAll(',', '')) ?? 0.0;

  // ── Helper: strip currency symbol/commas from a package price like "₹12,000" ──
  String _extractRateFromPrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(digits) ?? 0.0;
    return value.toStringAsFixed(2);
  }

  // ── When a package is selected in the dropdown for a row ─────────────────────
  void _onPackageSelected(_QuotationItemRow row, int packageId) {
    final pkg = _packages.firstWhere((p) => p['id'] == packageId, orElse: () => {});
    if (pkg.isEmpty) return;

    setState(() {
      row.packageId = packageId;
      row.descriptionCtrl.text = pkg['title'] ?? '';
      row.rateCtrl.text = _extractRateFromPrice(pkg['price']?.toString() ?? '0');
    });
  }

  // ── Add a new free-text row ("Add Section") ──────────────────────────────────
  void _addSection() {
    setState(() {
      _items.add(_QuotationItemRow(isPackageRow: false));
    });
  }

  // ── Remove a row ──────────────────────────────────────────────────────────────
  void _removeRow(int index) {
    if (_items.length <= 1) return; // keep at least one row
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  // ── Per-row computed values ───────────────────────────────────────────────────
  double _rowAmount(_QuotationItemRow row) {
    final qty = int.tryParse(row.qtyCtrl.text) ?? 1;
    final rate = _parseAmount(row.rateCtrl.text);
    return qty * rate;
  }

  double _rowPending(_QuotationItemRow row) {
    final amount = _rowAmount(row);
    final paid = _parseAmount(row.paidCtrl.text);
    final pending = amount - paid;
    return pending < 0 ? 0 : pending;
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── SAVE QUOTATION — POST to backend ────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════
  Future<bool> _saveQuotation(double subtotal, double tax, double total, double paid, double balance) async {
    final items = _items.map((row) => {
      "packageId": row.packageId,
      "description": row.descriptionCtrl.text.trim(),
      "qty": int.tryParse(row.qtyCtrl.text) ?? 1,
      "rate": _parseAmount(row.rateCtrl.text),
      "amount": _rowAmount(row),
      "paidAmount": _parseAmount(row.paidCtrl.text),
      "pendingAmount": _rowPending(row),
    }).toList();

    final payload = {
      "quotationNo": quotationNoController.text,
      "clientName": clientNameController.text,
      "quotationDate": dateController.text,
      "expiryDate": expiryController.text,
      "includeGST": includeGST,
      "subtotal": subtotal,
      "tax": tax,
      "totalAmount": total,
      "paidAmount": paid,
      "balanceAmount": balance,
      "items": items,
    };

    try {
      final isEdit = _quotationId != null;
      final response = isEdit
          ? await http.put(
              Uri.parse('$_baseUrl/quotations/$_quotationId'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
          : await http.post(
              Uri.parse('$_baseUrl/quotations'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(body['message'] ?? 'Failed to save quotation'),
            backgroundColor: Colors.redAccent,
          ));
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot connect to server'),
          backgroundColor: Colors.redAccent,
        ));
      }
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── PRINT QUOTATION — same visual format as the invoice PDF ────────────────────
  // ══════════════════════════════════════════════════════════════════════════════
  Future<void> _printQuotation(double total, double tax, double paid, double balance) async {

    // ── Load assets ───────────────────────────────────────────────────────────
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/godigital_logo.png'))
          .buffer.asUint8List(),
    );
    final sealImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/office_seal.png'))
          .buffer.asUint8List(),
    );

    // ── Load fonts ─────────────────────────────────────────────────────────────
    final font     = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final pdf = pw.Document();

    // ── Colors ─────────────────────────────────────────────────────────────────
    const PdfColor blue   = PdfColor.fromInt(0xFF0052CC);
    const PdfColor white  = PdfColor.fromInt(0xFFFFFFFF);
    const PdfColor grey   = PdfColor.fromInt(0xFFF0F0F0);
    const PdfColor bdrClr = PdfColor.fromInt(0xFF888888);

    // ── Rupee formatter ────────────────────────────────────────────────────────
    String fmt(double v) => '\u20B9 ${v.toStringAsFixed(0)} /-';

    // ── Reusable table cell ────────────────────────────────────────────────────
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

    // ── Summary row (TAX / TOTAL / PAID / BALANCE) ────────────────────────────
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

    // ── Build one item row for the PDF ────────────────────────────────────────
    pw.TableRow itemRow(int sNo, _QuotationItemRow row) {
      final qty = int.tryParse(row.qtyCtrl.text) ?? 1;
      final rate = _parseAmount(row.rateCtrl.text);
      final amount = _rowAmount(row);
      return pw.TableRow(children: [
        cell(sNo.toString(), align: pw.Alignment.center),
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            row.descriptionCtrl.text.isEmpty ? '-' : row.descriptionCtrl.text,
            style: pw.TextStyle(font: fontBold, fontSize: 9),
          ),
        ),
        cell(qty.toString(), align: pw.Alignment.center),
        cell(rate.toStringAsFixed(0), align: pw.Alignment.centerRight),
        cell(amount.toStringAsFixed(0), align: pw.Alignment.centerRight),
      ]);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [

              // ── TOP BLUE BAR ──────────────────────────────────────────────
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

              // ── MAIN BODY ─────────────────────────────────────────────────
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

                      // ── HEADER TABLE — Quotation No / Date / Valid Until ───
                      pw.Table(
                        border: pw.TableBorder.all(color: bdrClr, width: 0.5),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3),
                          1: const pw.FixedColumnWidth(95),
                          2: const pw.FixedColumnWidth(95),
                          3: const pw.FixedColumnWidth(95),
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
                              cell('Quotation No.', bold: true, size: 8, padV: 5),
                              cell(quotationNoController.text, size: 9, padV: 3),
                            ]),
                            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              cell('Quotation Date', bold: true, size: 8, padV: 5),
                              cell(dateController.text, size: 9, padV: 3),
                            ]),
                            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              cell('Valid Until', bold: true, size: 8, padV: 5),
                              cell(expiryController.text, size: 9, padV: 3),
                            ]),
                          ]),
                        ],
                      ),

                      // ── TO ROW ──────────────────────────────────────────
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
                                  pw.Text(clientNameController.text,
                                      style: pw.TextStyle(font: font, fontSize: 9)),
                                ],
                              ),
                            ),
                          ]),
                        ],
                      ),

                      pw.SizedBox(height: 4),

                      // ── ITEMS TABLE ─────────────────────────────────────
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
                          // ── One row per quotation line item ──────────────
                          for (int i = 0; i < _items.length; i++) itemRow(i + 1, _items[i]),
                          // ── TAX ROW — shown before TOTAL AMOUNT ───────────
                          summaryRow('TAX (18% GST)',      tax),
                          summaryRow('TOTAL AMOUNT',       total),
                          summaryRow('PAID AMOUNT',        paid),
                          summaryRow('BALANCE TO BE PAID', balance),
                        ],
                      ),

                      pw.SizedBox(height: 18),

                      // ── TERMS & CONDITIONS ────────────────────────────────
                      pw.Text('Terms & Conditions',
                          style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text('\u2022 This quotation is valid until the date mentioned above',
                          style: pw.TextStyle(font: font, fontSize: 9)),
                      pw.Text('\u2022 50% advance required to begin work',
                          style: pw.TextStyle(font: font, fontSize: 9)),
                      pw.Text('\u2022 Prices are subject to change after expiry',
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
                                    color: PdfColors.black,
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

                          // RIGHT — seal image
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

              // ── BOTTOM BLUE FOOTER BAR ──────────────────────────────────
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

  // ── Success popup shown after saving — button navigates to '/quotation' ─────
 void _showSavedSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300,   // minimum width
          maxWidth: 420,   // maximum width
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF16A34A), size: 32),
              ),
              const SizedBox(height: 16),
              const Text("Quotation Saved Successfully",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text("${quotationNoController.text} has been saved.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/quotation', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text("Go to Package & Quotation",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // ── MATH RUNTIME DATA PROPAGATION ENGINE ──
    double subtotal = 0;
    double overallPaid = 0;
    for (final row in _items) {
      subtotal += _rowAmount(row);
      overallPaid += _parseAmount(row.paidCtrl.text);
    }

    double tax = includeGST ? (subtotal * 0.18) : 0.00;
    double totalAmount = subtotal + tax;

    double balanceAmount = totalAmount - overallPaid;
    if (balanceAmount < 0) balanceAmount = 0;

    // ── While loading an existing quotation, show a spinner ──────────────────
    if (_loadingExisting) {
      return AdminLayout(
        pageTitle: "Create Quotation",
        currentRoute: "/quotation",
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: CircularProgressIndicator(color: Color(0xFF0052CC)),
          ),
        ),
      );
    }

    final pageTitle = _viewOnly
        ? "View Quotation"
        : (_quotationId != null ? "Edit Quotation" : "Create Quotation");

    return AdminLayout(
      pageTitle: pageTitle,
      currentRoute: "/quotation", // Maintains sidebar tab highlight state
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Toolbar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pageTitle,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
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
                  if (!_viewOnly)
                  ElevatedButton(
                    onPressed: _isSaving ? null : () async {
                      setState(() => _isSaving = true);
                      final ok = await _saveQuotation(subtotal, tax, totalAmount, overallPaid, balanceAmount);
                      setState(() => _isSaving = false);
                      if (ok && mounted) {
                        _showSavedSuccessDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Save Quotation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
                Expanded(child: _buildInlineFormInput("Client Name", clientNameController, readOnly: _viewOnly)),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerFormInput("Quotation Date", dateController)),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerFormInput("Expire Date", expiryController)), // Preserved typo label from image
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
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: const [
                      SizedBox(width: 40, child: Text("S.No", style: _tableLabelStyle)),
                      Expanded(flex: 5, child: Text("Description", style: _tableLabelStyle)),
                      SizedBox(width: 70, child: Text("QTY", textAlign: TextAlign.center, style: _tableLabelStyle)),
                      SizedBox(width: 100, child: Text("Rate", textAlign: TextAlign.right, style: _tableHeaderStyleRight)),
                      SizedBox(width: 110, child: Text("Amount", textAlign: TextAlign.right, style: _tableHeaderStyleRight)),
                      SizedBox(width: 120, child: Text("Paid Amount", textAlign: TextAlign.center, style: _tableLabelStyle)),
                      SizedBox(width: 130, child: Text("Pending Amount", textAlign: TextAlign.center, style: _tableLabelStyle)),
                      SizedBox(width: 30, child: Text("", style: _tableLabelStyle)),
                    ],
                  ),
                ),

                // ── One Row Per Line Item ────────────────────────────────────
                for (int i = 0; i < _items.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(width: 40, child: Text((i + 1).toString().padLeft(2, '0'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _items[i].isPackageRow
                                ? _buildPackageDropdown(_items[i])
                                : _buildDescriptionField(_items[i]),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _buildInnerNumInput(
                            _items[i].qtyCtrl,
                            textAlign: TextAlign.center,
                            readOnly: _viewOnly,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 100,
                          child: _items[i].isPackageRow
                              ? _buildReadOnlyRateField(_items[i].rateCtrl)
                              : _buildInnerNumInput(_items[i].rateCtrl, textAlign: TextAlign.right, readOnly: _viewOnly, onChanged: () => setState(() {})),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            "₹${_rowAmount(_items[i]).toStringAsFixed(2)}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
                              controller: _items[i].paidCtrl,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              readOnly: _viewOnly,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                              onChanged: (value) => setState(() {}),
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
                              "₹${_rowPending(_items[i]).toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _viewOnly
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () => _removeRow(i),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: _items.length > 1 ? const Color(0xFFDC2626) : Colors.grey.shade300,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _items.length - 1)
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Link Button — adds a free-text row ("Add Section")
          if (!_viewOnly)
          GestureDetector(
            onTap: _addSection,
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
                  _buildSummaryLineItem("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
                  const SizedBox(height: 14),

                  // ── Include 18% GST toggle ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Include 18% GST", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      Switch(
                        value: includeGST,
                        activeTrackColor: const Color(0xFF0052CC),
                        onChanged: _viewOnly ? null : (val) => setState(() => includeGST = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── TAX ROW — shown before Total Amount ─────────────────
                  _buildSummaryLineItem(
                    "Tax (18% GST)",
                    "₹${tax.toStringAsFixed(2)}",
                    highlightColor: includeGST ? null : Colors.grey,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                  _buildSummaryLineItem("Total Amount", "₹${totalAmount.toStringAsFixed(2)}", isBoldText: true, highlightColor: const Color(0xFF0052CC)),
                  const SizedBox(height: 14),

                  // ── Paid Amount — sum of all per-row Paid Amounts (read-only) ──
                  _buildSummaryLineItem("Paid Amount", "₹${overallPaid.toStringAsFixed(2)}", highlightColor: const Color(0xFF15803D)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                  _buildSummaryLineItem("Balance Amount", "₹${balanceAmount.toStringAsFixed(2)}", isBoldText: true, useFillBanner: true),
                  const SizedBox(height: 24),
                  
                  // ── Primary PDF Dispatch Button — saves + prints + shows success popup ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isPrinting ? null : () async {
                        setState(() => _isPrinting = true);

                        // ── View mode: just print, don't save/show success popup ──
                        if (_viewOnly) {
                          await _printQuotation(totalAmount, tax, overallPaid, balanceAmount);
                          if (!mounted) return;
                          setState(() => _isPrinting = false);
                          return;
                        }

                        final saved = await _saveQuotation(subtotal, tax, totalAmount, overallPaid, balanceAmount);
                        await _printQuotation(totalAmount, tax, overallPaid, balanceAmount);

                        if (!mounted) return;
                        setState(() => _isPrinting = false);

                        if (saved) {
                          _showSavedSuccessDialog();
                        }
                        // If saving failed, _saveQuotation already showed an error snackbar.
                      },
                      icon: _isPrinting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.print, size: 16, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      label: Text(_viewOnly ? "Print Quotation" : "Save & Print Quotation",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  // ── Date picker form input — opens native calendar, formats dd/MM/yyyy ──────
  Widget _buildDatePickerFormInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: _viewOnly ? null : () => _selectCalendarDate(context, controller),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
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

  // ── Package dropdown — fetched from /api/packages, used in the first row ─────
  Widget _buildPackageDropdown(_QuotationItemRow row) {
    // ── View mode: show plain text (avoids dropdown value-mismatch if the
    // package was edited/deleted after this quotation was saved) ──────────────
    if (_viewOnly) {
      return SizedBox(
        height: 38,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            row.descriptionCtrl.text.isEmpty ? '-' : row.descriptionCtrl.text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
        ),
      );
    }

    // Only offer packages whose id matches an existing option, else show hint
    final validValue = _packages.any((p) => p['id'] == row.packageId) ? row.packageId : null;

    return Container(
      height: 38,
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: _loadingPackages
          ? const Row(children: [
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0052CC))),
              SizedBox(width: 10),
              Text("Loading packages...", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ])
          : DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: validValue,
                isExpanded: true,
                hint: const Text("Select Package", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                items: _packages.map((pkg) {
                  return DropdownMenuItem<int>(
                    value: pkg['id'] as int,
                    child: Text(pkg['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) _onPackageSelected(row, val);
                },
              ),
            ),
    );
  }

  // ── Free-text description field — used for "Add Section" rows ────────────────
  Widget _buildDescriptionField(_QuotationItemRow row) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: row.descriptionCtrl,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        decoration: InputDecoration(
          hintText: "Enter description",
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
        ),
      ),
    );
  }

  // ── Read-only rate field — auto-filled from the selected package's price ─────
  Widget _buildReadOnlyRateField(TextEditingController controller) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        readOnly: true,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0052CC))),
        ),
      ),
    );
  }

  Widget _buildInnerNumInput(TextEditingController controller, {required TextAlign textAlign, bool readOnly = false, VoidCallback? onChanged}) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        readOnly: readOnly,
        onChanged: (_) => onChanged?.call(),
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