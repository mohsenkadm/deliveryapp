// خدمة توليد ملفات PDF — فواتير وتقارير بطباعة حرارية 80mm
//
// كل المخرجات مخصّصة لعرض إيصال بعرض 80mm (طابعات POS الحرارية).
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'branding_service.dart';

class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  /// عرض ورق الطابعة الحرارية: 80mm مع هوامش ضيقة للمحتوى الفعلي.
  static const PdfPageFormat receipt80 = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginAll: 3 * PdfPageFormat.mm,
  );

  pw.Font? _arabicRegular;
  pw.Font? _arabicBold;

  Future<void> _ensureFonts() async {
    if (_arabicRegular != null && _arabicBold != null) return;
    try {
      _arabicRegular = await PdfGoogleFonts.cairoRegular();
      _arabicBold = await PdfGoogleFonts.cairoBold();
    } catch (_) {
      _arabicRegular = pw.Font.helvetica();
      _arabicBold = pw.Font.helveticaBold();
    }
  }

  pw.ThemeData get _theme => pw.ThemeData.withFont(
        base: _arabicRegular!,
        bold: _arabicBold!,
      );

  BrandingService get _branding => Get.find<BrandingService>();

  // ════════════════════════════════════════
  //  فاتورة — إيصال 80mm
  // ════════════════════════════════════════
  Future<Uint8List> buildInvoicePdf(Map<String, dynamic> invoice) async {
    await _ensureFonts();
    if (invoice['layout'] == 'rep_sales') {
      return _buildRepSalesInvoicePdf(invoice);
    }
    return _buildStandardInvoicePdf(invoice);
  }

  Future<Uint8List> _buildStandardInvoicePdf(
      Map<String, dynamic> invoice) async {
    final doc = pw.Document(theme: _theme);
    final brandName = _branding.appName.value;
    final logoBytes = await _loadLogoBytes();
    final qrData =
        'INV:${invoice['id'] ?? invoice['invoiceNumber'] ?? ''}|${invoice['total'] ?? 0}';
    final items = (invoice['items'] as List?) ?? const [];

    doc.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: receipt80,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _receiptHeader(brandName, logoBytes),
            pw.SizedBox(height: 6),
            _dashedLine(),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'فاتورة مبيعات',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            _receiptMeta(invoice),
            pw.SizedBox(height: 6),
            _dashedLine(),
            pw.SizedBox(height: 4),
            _receiptItems(items),
            pw.SizedBox(height: 4),
            _dashedLine(),
            pw.SizedBox(height: 4),
            _receiptTotals(invoice),
            if ((invoice['notes'] ?? '').toString().trim().isNotEmpty) ...[
              pw.SizedBox(height: 6),
              _receiptNotes(invoice['notes'].toString()),
            ],
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qrData,
                width: 64,
                height: 64,
              ),
            ),
            pw.SizedBox(height: 8),
            _dashedLine(),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'شكراً لتعاملكم معنا',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                brandName,
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                _nowStamp(),
                style: const pw.TextStyle(
                  fontSize: 6.5,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  /// إيصال مندوب — ترتيب فاتورة مبيعات حرارية (مثل إيصال حضارة لارسا).
  Future<Uint8List> _buildRepSalesInvoicePdf(
      Map<String, dynamic> invoice) async {
    final doc = pw.Document(theme: _theme);
    final brandAr = _branding.appName.value;
    final brandEn =
        (invoice['companyNameEn'] ?? _branding.companySlogan.value).toString();
    final logoBytes = await _loadLogoBytes();
    final items = (invoice['items'] as List?) ?? const [];

    doc.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: receipt80,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _repSalesHeader(
              logoBytes: logoBytes,
              brandEn: brandEn.isNotEmpty ? brandEn : brandAr,
              brandAr: brandAr,
              addressPhone: _repAddressPhoneLine(invoice),
              repLine: _repRepresentativeLine(invoice),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'فاتورة مبيعات - ${invoice['paymentType'] ?? 'نقداً'}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            _repSalesMetaTable(invoice),
            pw.SizedBox(height: 6),
            _repSalesItemsTable(items),
            pw.SizedBox(height: 6),
            _repSalesSummaryTable(invoice),
            pw.SizedBox(height: 6),
            if ((invoice['notes'] ?? '').toString().trim().isNotEmpty)
              _receiptNotes(invoice['notes'].toString()),
          ],
        ),
      ),
    );
    return doc.save();
  }

  String _repAddressPhoneLine(Map<String, dynamic> invoice) {
    final addr = (invoice['companyAddress'] ??
            _branding.companyAddress.value)
        .toString()
        .trim();
    final phone = (invoice['companyPhone'] ?? _branding.companyPhone.value)
        .toString()
        .trim();
    if (addr.isNotEmpty && phone.isNotEmpty) return '$addr $phone';
    if (addr.isNotEmpty) return addr;
    if (phone.isNotEmpty) return phone;
    return '';
  }

  String _repRepresentativeLine(Map<String, dynamic> invoice) {
    final name = (invoice['repName'] ?? '').toString().trim();
    final phone = (invoice['repPhone'] ?? '').toString().trim();
    if (name.isEmpty && phone.isEmpty) return '';
    if (phone.isEmpty) return 'المندوب $name';
    if (name.isEmpty) return 'المندوب $phone';
    return 'المندوب $name $phone';
  }

  pw.Widget _repSalesHeader({
    required Uint8List? logoBytes,
    required String brandEn,
    required String brandAr,
    required String addressPhone,
    required String repLine,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoBytes != null)
          pw.ClipRRect(
            horizontalRadius: 4,
            verticalRadius: 4,
            child: pw.Image(
              pw.MemoryImage(logoBytes),
              width: 40,
              height: 40,
              fit: pw.BoxFit.cover,
            ),
          ),
        if (logoBytes != null) pw.SizedBox(height: 4),
        if (brandEn.isNotEmpty)
          pw.Text(
            brandEn.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        pw.Text(
          brandAr,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        if (addressPhone.isNotEmpty)
          pw.Text(
            addressPhone,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
          ),
        if (repLine.isNotEmpty)
          pw.Text(
            repLine,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
          ),
      ],
    );
  }

  pw.Widget _repSalesMetaTable(Map<String, dynamic> inv) {
    final invNum = inv['invoiceNumber'] ?? inv['id'] ?? '';
    final date = _formatInvoiceDate(inv['date'] ?? inv['createdAt'] ?? '');
    final customer = inv['customerName']?.toString() ?? '-';
    return _borderedKeyValueTable([
      ('الرقم', invNum.toString()),
      ('التاريخ', date),
      ('العميل', customer),
    ]);
  }

  pw.Widget _repSalesItemsTable(List items) {
    if (items.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'لا توجد أصناف',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      );
    }

    var totalQty = 0;
    var totalAmount = 0.0;
    final rows = <pw.TableRow>[];

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _repCell('الاجمالي', bold: true, align: pw.TextAlign.center),
          _repCell('السعر', bold: true, align: pw.TextAlign.center),
          _repCell('الكمية', bold: true, align: pw.TextAlign.center),
          _repCell('الصنف', bold: true),
          _repCell('#', bold: true, align: pw.TextAlign.center),
        ],
      ),
    );

    for (var i = 0; i < items.length; i++) {
      final it = items[i] as Map;
      final name = (it['name'] ?? it['productName'] ?? '').toString();
      final qty = _asNum(it['quantity'] ?? 0).round();
      final price = _asNum(it['price'] ?? it['unitPrice'] ?? 0);
      final lineTotal = _asNum(
        it['total'] ?? it['lineTotal'] ?? (qty * price),
      );
      totalQty += qty;
      totalAmount += lineTotal;

      rows.add(
        pw.TableRow(
          children: [
            _repCell(_fmtMoney(lineTotal),
                align: pw.TextAlign.center, bold: true),
            _repCell(_fmtMoney(price), align: pw.TextAlign.center),
            _repCell('$qty', align: pw.TextAlign.center),
            _repCell(name, maxLines: 2),
            _repCell('${i + 1}', align: pw.TextAlign.center),
          ],
        ),
      );
    }

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          _repCell(_fmtMoney(totalAmount),
              bold: true, align: pw.TextAlign.center),
          _repCell('', align: pw.TextAlign.center),
          _repCell('$totalQty', bold: true, align: pw.TextAlign.center),
          _repCell('', ),
          _repCell('', align: pw.TextAlign.center),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(4),
        4: const pw.FlexColumnWidth(1),
      },
      children: rows,
    );
  }

  pw.Widget _repSalesSummaryTable(Map<String, dynamic> inv) {
    final previous = _asNum(
      inv['previousBalance'] ?? inv['customerPreviousBalance'] ?? 0,
    );
    final invoiceTotal = _asNum(inv['total'] ?? inv['totalAmount'] ?? 0);
    final discount = _asNum(inv['discount'] ?? 0);
    final grandTotal = _asNum(
      inv['grandTotal'] ?? (previous + invoiceTotal - discount),
    );
    final paid = _asNum(inv['paid'] ?? inv['paidAmount'] ?? 0);
    final current = _asNum(
      inv['currentBalance'] ?? (grandTotal - paid),
    );

    return _borderedKeyValueTable([
      ('الحساب السابق (عليكم)', _fmtMoney(previous)),
      ('إجمالي الفاتورة', _fmtMoney(invoiceTotal)),
      ('الاجمالي', _fmtMoney(grandTotal)),
      ('المدفوع', _fmtMoney(paid)),
      ('الحساب الحالي', _fmtMoney(current)),
    ], valueBoldLast: true);
  }

  pw.Widget _borderedKeyValueTable(
    List<(String, String)> rows, {
    bool valueBoldLast = false,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(5),
        1: const pw.FlexColumnWidth(4),
      },
      children: rows.asMap().entries.map((entry) {
        final i = entry.key;
        final (label, value) = entry.value;
        final isLast = valueBoldLast && i == rows.length - 1;
        return pw.TableRow(
          children: [
            _repCell(label, bold: true),
            _repCell(value, bold: isLast, align: pw.TextAlign.center),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _repCell(
    String text, {
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.right,
    int maxLines = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: pw.Text(
        text,
        textAlign: align,
        maxLines: maxLines,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatInvoiceDate(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.length >= 10) return s.substring(0, 10);
    return s.isEmpty ? '-' : s;
  }

  num _asNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  String _fmtMoney(dynamic value) {
    final n = _asNum(value);
    final intVal = n.round();
    final negative = intVal < 0;
    final abs = negative ? -intVal : intVal;
    final formatted = abs.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return negative ? '-$formatted' : formatted;
  }

  // ════════════════════════════════════════
  //  تقرير — إيصال 80mm
  // ════════════════════════════════════════
  Future<Uint8List> buildReportPdf({
    required String title,
    String? subtitle,
    required List<String> headers,
    required List<List<String>> rows,
    Map<String, String>? summary,
  }) async {
    await _ensureFonts();
    final doc = pw.Document(theme: _theme);
    final brandName = _branding.appName.value;
    final logoBytes = await _loadLogoBytes();

    // صفحات متعددة بعرض 80mm وارتفاع عملي للتقارير الطويلة
    final pageFormat = PdfPageFormat(
      80 * PdfPageFormat.mm,
      297 * PdfPageFormat.mm,
      marginAll: 3 * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        pageFormat: pageFormat,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _receiptHeader(brandName, logoBytes, compact: true),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  subtitle,
                  style: const pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            pw.SizedBox(height: 4),
            _dashedLine(),
            pw.SizedBox(height: 4),
          ],
        ),
        footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Center(
            child: pw.Text(
              'صفحة ${ctx.pageNumber}/${ctx.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 6.5,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
        build: (ctx) => [
          if (summary != null && summary.isNotEmpty) ...[
            _receiptSummary(summary),
            pw.SizedBox(height: 6),
            _dashedLine(),
            pw.SizedBox(height: 4),
          ],
          ..._reportRows(headers, rows),
        ],
      ),
    );
    return doc.save();
  }

  // ════════════════════════════════════════
  //  طباعة / مشاركة
  // ════════════════════════════════════════
  Future<void> printOrPreview(Uint8List bytes, {String? name}) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name ?? 'receipt.pdf',
      format: receipt80,
    );
  }

  Future<void> shareBytes(Uint8List bytes, {String? name}) async {
    final dir = await getTemporaryDirectory();
    final filename = '${name ?? 'receipt'}.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], subject: name);
  }

  // ════════════════════════════════════════
  //  مكوّنات الإيصال 80mm
  // ════════════════════════════════════════
  pw.Widget _receiptHeader(
    String brand,
    Uint8List? logo, {
    bool compact = false,
  }) {
    final logoSize = compact ? 28.0 : 36.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null)
          pw.ClipRRect(
            horizontalRadius: 4,
            verticalRadius: 4,
            child: pw.Image(
              pw.MemoryImage(logo),
              width: logoSize,
              height: logoSize,
              fit: pw.BoxFit.cover,
            ),
          )
        else
          pw.SizedBox(height: 2),
        pw.SizedBox(height: 4),
        pw.Text(
          brand,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: compact ? 10 : 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (_branding.companySlogan.value.isNotEmpty)
          pw.Text(
            _branding.companySlogan.value,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
        if (_branding.companyAddress.value.isNotEmpty)
          pw.Text(
            _branding.companyAddress.value,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
        if (_branding.companyPhone.value.isNotEmpty)
          pw.Text(
            'هاتف: ${_branding.companyPhone.value}',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
      ],
    );
  }

  pw.Widget _receiptMeta(Map<String, dynamic> inv) {
    final invNum = inv['invoiceNumber'] ?? inv['id'] ?? '';
    final date = inv['date'] ?? inv['createdAt'] ?? '';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _line('رقم الفاتورة', '#$invNum'),
        _line('التاريخ', date.toString()),
        if ((inv['status'] ?? '').toString().isNotEmpty)
          _line('الحالة', inv['status'].toString()),
        pw.SizedBox(height: 4),
        _line('العميل', inv['customerName']?.toString() ?? '-'),
        if ((inv['storeName'] ?? '').toString().isNotEmpty)
          _line('المتجر', inv['storeName'].toString()),
        if ((inv['phone'] ?? '').toString().isNotEmpty)
          _line('الهاتف', inv['phone'].toString()),
        if ((inv['address'] ?? '').toString().isNotEmpty)
          _line('العنوان', inv['address'].toString()),
      ],
    );
  }

  pw.Widget _receiptItems(List items) {
    if (items.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'لا توجد أصناف',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // رأس الأعمدة
        pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.Text(
                'الصنف',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(
              width: 28,
              child: pw.Text(
                'كمية',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(
              width: 42,
              child: pw.Text(
                'السعر',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(
              width: 48,
              child: pw.Text(
                'المجموع',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        _dashedLine(),
        pw.SizedBox(height: 2),
        for (var i = 0; i < items.length; i++) ...[
          _itemRow(i + 1, items[i] as Map),
          if (i < items.length - 1) pw.SizedBox(height: 3),
        ],
      ],
    );
  }

  pw.Widget _itemRow(int index, Map it) {
    final name = (it['name'] ?? it['productName'] ?? '').toString();
    final qty = _fmtNum(it['quantity'] ?? 0);
    final unit = (it['unit'] ?? '').toString();
    final price = _fmtNum(it['price'] ?? it['unitPrice'] ?? 0);
    final total = _fmtNum(it['total'] ?? it['lineTotal'] ?? 0);
    final qtyLabel = unit.isEmpty ? qty : '$qty $unit';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          '$index. $name',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          maxLines: 2,
        ),
        pw.SizedBox(height: 1),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.SizedBox(),
            ),
            pw.SizedBox(
              width: 28,
              child: pw.Text(
                qtyLabel,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 7.5),
              ),
            ),
            pw.SizedBox(
              width: 42,
              child: pw.Text(
                price,
                textAlign: pw.TextAlign.left,
                style: const pw.TextStyle(fontSize: 7.5),
              ),
            ),
            pw.SizedBox(
              width: 48,
              child: pw.Text(
                total,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _receiptTotals(Map<String, dynamic> inv) {
    final subtotal = _fmtNum(inv['subtotal'] ?? inv['totalAmount'] ?? 0);
    final discount = _fmtNum(inv['discount'] ?? 0);
    final total = _fmtNum(inv['total'] ?? inv['totalAmount'] ?? 0);
    final paid = _fmtNum(inv['paid'] ?? inv['paidAmount'] ?? 0);
    final remainingRaw = inv['remaining'];
    final remaining = remainingRaw == null || remainingRaw.toString().isEmpty
        ? ''
        : _fmtNum(remainingRaw);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _line('المجموع الجزئي', subtotal),
        _line('الخصم', discount),
        pw.SizedBox(height: 2),
        _line('الإجمالي', total, bold: true, size: 10),
        _line('المدفوع', paid),
        if (remaining.isNotEmpty)
          _line('المتبقي', remaining, bold: true),
      ],
    );
  }

  pw.Widget _receiptNotes(String notes) => pw.Container(
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ملاحظات',
              style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(notes, style: const pw.TextStyle(fontSize: 7.5)),
          ],
        ),
      );

  pw.Widget _receiptSummary(Map<String, String> summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: summary.entries
          .map((e) => _line(e.key, e.value, bold: true))
          .toList(),
    );
  }

  List<pw.Widget> _reportRows(List<String> headers, List<List<String>> rows) {
    final widgets = <pw.Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 4),
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              for (var c = 0; c < headers.length; c++)
                if (c < row.length)
                  _line(headers[c], row[c], size: 7.5),
            ],
          ),
        ),
      );
    }
    if (widgets.isEmpty) {
      widgets.add(
        pw.Center(
          child: pw.Text(
            'لا توجد بيانات',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
      );
    }
    return widgets;
  }

  pw.Widget _line(
    String label,
    String value, {
    bool bold = false,
    double size = 8,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: size,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            flex: 6,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: size,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// فاصل نصي أوضح وأكثر ثباتاً على الطابعات الحرارية من الخطوط PDF.
  pw.Widget _dashedLine() => pw.Center(
        child: pw.Text(
          '- - - - - - - - - - - - - - - - - -',
          style: const pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey600,
            letterSpacing: 0.5,
          ),
        ),
      );

  String _fmtNum(dynamic value) {
    if (value == null) return '0';
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value.toStringAsFixed(2);
    }
    final parsed = num.tryParse(value.toString());
    if (parsed == null) return value.toString();
    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }
    return parsed.toStringAsFixed(2);
  }

  String _nowStamp() {
    final n = DateTime.now();
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    final h = n.hour.toString().padLeft(2, '0');
    final min = n.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  Future<Uint8List?> _loadLogoBytes() async {
    final path = _branding.logoPath.value;
    if (path == null || path.isEmpty) return null;
    try {
      if (path.startsWith('assets/')) {
        final data = await rootBundle.load(path);
        return data.buffer.asUint8List();
      }
      final file = File(path);
      if (await file.exists()) return await file.readAsBytes();
    } catch (_) {}
    return null;
  }
}
