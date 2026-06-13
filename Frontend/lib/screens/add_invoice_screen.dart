import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../layouts/admin_layout.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

// ── One line-item row in the invoice table ───────────────────────────────────
// isPackageRow = true  → first row, description comes from a Package dropdown
//                         (rate auto-fills from the selected package's price)
// isPackageRow = false → "Add Section" rows, description is free text,
//                         rate is editable manually
class _InvoiceItemRow {
  int? packageId;
  bool isPackageRow;
  final TextEditingController descriptionCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController paidCtrl;

  _InvoiceItemRow({
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

class AddInvoiceScreen extends StatefulWidget {
  final int? invoiceId;
  final bool viewOnly;

  const AddInvoiceScreen({super.key, this.invoiceId, this.viewOnly = false});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  // ── API base URL ──────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://localhost:3000/api';

  final invoiceNoController = TextEditingController(text: "Loading...");
  final dateController = TextEditingController();
  final maintenanceDateController = TextEditingController();
  final clientNameController = TextEditingController(text: "GA MALL");
  final discountController = TextEditingController(text: "0.00");
  final notesController = TextEditingController();

  bool agreedToTerms = false;
  bool includeGST = true;
  bool _isSaving = false;
  bool _isPrinting = false;

  // ── Edit / View mode state ────────────────────────────────────────────────────
  int? _invoiceId;     // null = creating a new invoice
  bool _viewOnly = false;
  bool _loadingExisting = false;
  bool _argsProcessed = false;

  // ── Packages fetched from backend, used to populate the deliverable dropdown ──
  List<Map<String, dynamic>> _packages = [];
  bool _loadingPackages = true;

  // ── Line items — starts with one package-driven row ──────────────────────────
  late List<_InvoiceItemRow> _items;

  @override
  void initState() {
    super.initState();
    _items = [_InvoiceItemRow(isPackageRow: true)];
    final now = DateTime.now();
    dateController.text = DateFormat('dd/MM/yyyy').format(now);
    maintenanceDateController.text = DateFormat('dd/MM/yyyy').format(now.add(const Duration(days: 30)));
    _fetchPackages();

    _invoiceId = widget.invoiceId;
    _viewOnly = widget.viewOnly;
    if (_invoiceId != null) {
      _loadExistingInvoice(_invoiceId!);
    } else {
      _fetchNextInvoiceNumber();
    }
  }

  // ── Also support passing { invoiceId, viewOnly } via Navigator arguments ────
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsProcessed) return;
    _argsProcessed = true;

    if (widget.invoiceId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final id = args['invoiceId'];
        final view = args['viewOnly'] == true;
        if (id is int) {
          setState(() {
            _invoiceId = id;
            _viewOnly = view;
          });
          _loadExistingInvoice(id);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    invoiceNoController.dispose();
    dateController.dispose();
    maintenanceDateController.dispose();
    clientNameController.dispose();
    discountController.dispose();
    notesController.dispose();
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

  // ── FETCH next auto-generated invoice number ─────────────────────────────────
  Future<void> _fetchNextInvoiceNumber() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/invoices/next-number'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() => invoiceNoController.text = body['data']['invoiceNo']);
      } else {
        setState(() => invoiceNoController.text = "INV-2026-0842");
      }
    } catch (e) {
      setState(() => invoiceNoController.text = "INV-2026-0842");
    }
  }

  // ── Load an existing invoice (for View / Edit) ───────────────────────────────
  Future<void> _loadExistingInvoice(int id) async {
    setState(() => _loadingExisting = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/invoices/$id'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        for (final item in _items) {
          item.dispose();
        }

        final List<_InvoiceItemRow> loadedItems = [];
        for (final it in (data['items'] as List)) {
          loadedItems.add(_InvoiceItemRow(
            isPackageRow: it['package_id'] != null,
            packageId: it['package_id'],
            description: it['description'] ?? '',
            qty: (it['qty'] ?? 1).toString(),
            rate: double.tryParse(it['rate'].toString())?.toStringAsFixed(2) ?? '0.00',
            paid: double.tryParse(it['paid_amount'].toString())?.toStringAsFixed(2) ?? '0.00',
          ));
        }

        setState(() {
          invoiceNoController.text = data['invoice_no'] ?? '';
          clientNameController.text = data['client_name'] ?? '';
          dateController.text = data['invoice_date'] ?? '';
          maintenanceDateController.text = data['maintenance_date'] ?? '';
          discountController.text = double.tryParse(data['discount'].toString())?.toStringAsFixed(2) ?? '0.00';
          notesController.text = data['notes'] ?? '';
          includeGST = data['include_gst'] == 1 || data['include_gst'] == true;
          _items = loadedItems.isNotEmpty ? loadedItems : [_InvoiceItemRow(isPackageRow: true)];
          _loadingExisting = false;
        });
      } else {
        setState(() => _loadingExisting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to load invoice'),
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

  // ── Helper: parse "12,000.00" style strings ──────────────────────────────────
  double _parseAmount(String text) => double.tryParse(text.replaceAll(',', '')) ?? 0.0;

  // ── Helper: strip currency symbol/commas from a package price like "₹12,000" ──
  String _extractRateFromPrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(digits) ?? 0.0;
    return value.toStringAsFixed(2);
  }

  // ── When a package is selected in the dropdown for a row ─────────────────────
  void _onPackageSelected(_InvoiceItemRow row, int packageId) {
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
      _items.add(_InvoiceItemRow(isPackageRow: false));
    });
  }

  // ── Remove a row ──────────────────────────────────────────────────────────────
  void _removeRow(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  // ── Per-row computed values ───────────────────────────────────────────────────
  double _rowAmount(_InvoiceItemRow row) {
    final qty = int.tryParse(row.qtyCtrl.text) ?? 1;
    final rate = _parseAmount(row.rateCtrl.text);
    return qty * rate;
  }

  double _rowPending(_InvoiceItemRow row) {
    final amount = _rowAmount(row);
    final paid = _parseAmount(row.paidCtrl.text);
    final pending = amount - paid;
    return pending < 0 ? 0 : pending;
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ── SAVE INVOICE — POST/PUT to backend ──────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════
  Future<bool> _saveInvoice(double subtotal, double discount, double tax, double total, double paid, double balance) async {
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
      "invoiceNo": invoiceNoController.text,
      "clientName": clientNameController.text,
      "invoiceDate": dateController.text,
      "maintenanceDate": maintenanceDateController.text,
      "includeGST": includeGST,
      "discount": discount,
      "notes": notesController.text,
      "subtotal": subtotal,
      "tax": tax,
      "totalAmount": total,
      "paidAmount": paid,
      "balanceAmount": balance,
      "items": items,
    };

    try {
      final isEdit = _invoiceId != null;
      final response = isEdit
          ? await http.put(
              Uri.parse('$_baseUrl/invoices/$_invoiceId'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
          : await http.post(
              Uri.parse('$_baseUrl/invoices'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(body['message'] ?? 'Failed to save invoice'),
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

  // ── Success popup shown after saving — button navigates to '/invoice' ───────
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
                decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 32),
              ),
              const SizedBox(height: 16),
              const Text("Invoice Saved Successfully",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text("${invoiceNoController.text} has been saved.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/invoice', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text("Go to Invoices",
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

  // ── Helper to prompt the native calendar view dialog sheet (dd/MM/yyyy) ──────
  Future<void> _selectCalendarDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      }
    } catch (_) {}

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

  // ══════════════════════════════════════════════════════════════════════════════
  // ── PRINT INVOICE ────────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════════
  Future<void> _printInvoice(double subtotal, double discount, double tax, double total, double paid, double balance) async {

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

    // ── Summary row (DISCOUNT / TAX / TOTAL / PAID / BALANCE) ─────────────────────
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
    pw.TableRow itemRow(int sNo, _InvoiceItemRow row) {
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
                                  pw.Text(clientNameController.text,
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
                          // ── One row per invoice line item ──────────────────
                          for (int i = 0; i < _items.length; i++) itemRow(i + 1, _items[i]),
                          // ── DISCOUNT ROW — only if discount applied ────────
                          if (discount > 0) summaryRow('DISCOUNT', -discount),
                          // ── TAX ROW — shown before TOTAL AMOUNT ────────────
                          summaryRow('TAX (18% GST)',      tax),
                          summaryRow('TOTAL AMOUNT',       total),
                          summaryRow('PAID AMOUNT',        paid),
                          summaryRow('BALANCE TO BE PAID', balance),
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

  @override
  Widget build(BuildContext context) {
    // ── MATH RUNTIME DATA PROPAGATION ENGINE ──
    double subtotal = 0;
    double overallPaid = 0;
    for (final row in _items) {
      subtotal += _rowAmount(row);
      overallPaid += _parseAmount(row.paidCtrl.text);
    }

    double discount = _parseAmount(discountController.text);
    double taxableAmount = subtotal - discount;
    if (taxableAmount < 0) taxableAmount = 0;

    double tax = includeGST ? (taxableAmount * 0.18) : 0.00;
    double totalAmount = taxableAmount + tax;

    double balanceAmount = totalAmount - overallPaid;
    if (balanceAmount < 0) balanceAmount = 0;

    // ── While loading an existing invoice, show a spinner ─────────────────────
    if (_loadingExisting) {
      return AdminLayout(
        pageTitle: "Add Invoice",
        currentRoute: "/invoice",
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: CircularProgressIndicator(color: Color(0xFF0052CC)),
          ),
        ),
      );
    }

    final pageTitle = _viewOnly
        ? "View Invoice"
        : (_invoiceId != null ? "Edit Invoice" : "Add Invoice");

    return AdminLayout(
      pageTitle: pageTitle,
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
                children: [
                  Text(
                    pageTitle,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
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
                  if (!_viewOnly)
                  ElevatedButton(
                    onPressed: _isSaving ? null : () async {
                      setState(() => _isSaving = true);
                      final ok = await _saveInvoice(subtotal, discount, tax, totalAmount, overallPaid, balanceAmount);
                      setState(() => _isSaving = false);
                      if (ok && mounted) {
                        _showSavedSuccessDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Save Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
                Expanded(child: _buildInlineFormInput("Client Name", clientNameController, readOnly: _viewOnly)),
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

                // ── One Row Per Line Item ────────────────────────────────────
                for (int i = 0; i < _items.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(width: 45, child: Text((i + 1).toString().padLeft(2, '0'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),

                        Expanded(flex: 6, child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _items[i].isPackageRow
                              ? _buildPackageDropdown(_items[i])
                              : _buildDescriptionField(_items[i]),
                        )),

                        SizedBox(width: 60, child: _buildInnerNumInput(
                          _items[i].qtyCtrl,
                          textAlign: TextAlign.center,
                          readOnly: _viewOnly,
                          fillBg: false,
                          onChanged: () => setState(() {}),
                        )),
                        const SizedBox(width: 8),

                        SizedBox(width: 100, child: _items[i].isPackageRow
                            ? _buildInnerNumInput(_items[i].rateCtrl, textAlign: TextAlign.right, readOnly: true, fillBg: true)
                            : _buildInnerNumInput(_items[i].rateCtrl, textAlign: TextAlign.right, readOnly: _viewOnly, fillBg: false, onChanged: () => setState(() {}))),

                        SizedBox(
                          width: 110,
                          child: Text(
                            "₹${_rowAmount(_items[i]).toStringAsFixed(2)}",
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Notes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: notesController,
                                  maxLines: 3,
                                  readOnly: _viewOnly,
                                  decoration: InputDecoration(
                                    hintText: "Enter internal notes or comments...",
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0052CC))),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                        onChanged: _viewOnly ? null : (val) => setState(() => agreedToTerms = val!),
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
                              _buildBankItem("Name", "GO DIGITAL"),
                              _buildBankItem("Bank", "IDFC FIRST\nBANK"),
                              _buildBankItem("A/C Number", "10075087276"),
                              _buildBankItem("IFSC / Branch", "IDFB0080121\nKILPAUK"),
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
                      _buildSummaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
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
                              readOnly: _viewOnly,
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
                            activeTrackColor: const Color(0xFF0052CC),
                            onChanged: _viewOnly ? null : (bool value) {
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

                      // ── Paid Amount — sum of all per-row Paid Amounts (read-only) ──
                      _buildSummaryRow("Paid Amount", "₹${overallPaid.toStringAsFixed(2)}", textColor: const Color(0xFF15803D)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                      _buildSummaryRow("Balance Amount", "₹${balanceAmount.toStringAsFixed(2)}", isBold: true, isBanner: true),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isPrinting ? null : () async {
                            setState(() => _isPrinting = true);

                            if (_viewOnly) {
                              await _printInvoice(subtotal, discount, tax, totalAmount, overallPaid, balanceAmount);
                              if (!mounted) return;
                              setState(() => _isPrinting = false);
                              return;
                            }

                            final saved = await _saveInvoice(subtotal, discount, tax, totalAmount, overallPaid, balanceAmount);
                            await _printInvoice(subtotal, discount, tax, totalAmount, overallPaid, balanceAmount);

                            if (!mounted) return;
                            setState(() => _isPrinting = false);

                            if (saved) {
                              _showSavedSuccessDialog();
                            }
                          },
                          icon: _isPrinting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.print, size: 16, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          label: Text(_viewOnly ? "Print Invoice" : "Save & Print Invoice",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
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
            readOnly: true,
            onTap: _viewOnly ? null : () => _selectCalendarDate(context, controller),
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

  // ── Package dropdown — fetched from /api/packages, used in the first row ─────
  Widget _buildPackageDropdown(_InvoiceItemRow row) {
    if (_viewOnly) {
      return SizedBox(
        height: 36,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            row.descriptionCtrl.text.isEmpty ? '-' : row.descriptionCtrl.text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
        ),
      );
    }

    final validValue = _packages.any((p) => p['id'] == row.packageId) ? row.packageId : null;

    return Container(
      height: 36,
      constraints: const BoxConstraints(maxWidth: 240),
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
                hint: const Text("Select Package", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                items: _packages.map((pkg) {
                  return DropdownMenuItem<int>(
                    value: pkg['id'] as int,
                    child: Text(pkg['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
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
  Widget _buildDescriptionField(_InvoiceItemRow row) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: row.descriptionCtrl,
        readOnly: _viewOnly,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
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

  Widget _buildInnerNumInput(TextEditingController controller, {required TextAlign textAlign, bool readOnly = false, bool fillBg = false, VoidCallback? onChanged}) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        readOnly: readOnly,
        onChanged: (_) => onChanged?.call(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        decoration: InputDecoration(
          filled: fillBg,
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