// خدمة توليد ملفات PDF — للفواتير والتقارير
//
// ميزات:
//   - دعم اللغة العربية (خط Cairo من Google Fonts)
//   - توليد فاتورة مع QR Code وشعار الشركة
//   - تصدير تقارير المبيعات/التحصيل/الديون كجدول
//   - مشاركة وطباعة الملف الناتج
//
// تستخدم: pdf, printing, qr_flutter (للـ QR في الواجهة), share_plus
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

  // ── أصول الخطوط (تُحمّل عند الحاجة) ──
  pw.Font? _arabicRegular;
  pw.Font? _arabicBold;

  Future<void> _ensureFonts() async {
    if (_arabicRegular != null && _arabicBold != null) return;
    try {
      _arabicRegular = await PdfGoogleFonts.cairoRegular();
      _arabicBold = await PdfGoogleFonts.cairoBold();
    } catch (_) {
      // fallback لخط افتراضي إن فشل التحميل (بدون انترنت مثلاً)
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
  //  فاتورة مبيعات / تجهيز
  // ════════════════════════════════════════
  /// [invoice] خريطة بحقول: id, invoiceNumber, date, customerName, storeName,
  /// phone, address, items (قائمة: name, quantity, unit, price, total),
  /// subtotal, discount, total, paid, remaining, notes
  Future<Uint8List> buildInvoicePdf(Map<String, dynamic> invoice) async {
    await _ensureFonts();
    final doc = pw.Document(theme: _theme);
    final brandName = _branding.appName.value;
    final logoBytes = await _loadLogoBytes();
    final qrData =
        'INV:${invoice['id'] ?? invoice['invoiceNumber'] ?? ''}|${invoice['total'] ?? 0}';

    final items = (invoice['items'] as List?) ?? const [];

    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) => [
          _header(brandName, logoBytes, qrData, invoice),
          pw.SizedBox(height: 14),
          _customerBlock(invoice),
          pw.SizedBox(height: 14),
          _itemsTable(items),
          pw.SizedBox(height: 14),
          _totalsBlock(invoice),
          if ((invoice['notes'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _notesBlock(invoice['notes'].toString()),
          ],
          pw.SizedBox(height: 24),
          _footer(brandName),
        ],
      ),
    );
    return doc.save();
  }

  // ════════════════════════════════════════
  //  تقرير عام (مبيعات/تحصيل/ديون)
  // ════════════════════════════════════════
  /// [headers] رؤوس الأعمدة، [rows] الصفوف، [title] عنوان التقرير،
  /// [subtitle] فترة/فلاتر، [summary] خريطة ملخص (label -> value)
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

    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: _reportHeader(brandName, logoBytes, title, subtitle),
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'صفحة ${ctx.pageNumber} من ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) => [
          if (summary != null && summary.isNotEmpty) ...[
            _summaryBox(summary),
            pw.SizedBox(height: 12),
          ],
          pw.Table.fromTextArray(
            headers: headers,
            data: rows,
            cellAlignment: pw.Alignment.center,
            headerAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(_branding.primaryColorValue.value),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9.5),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4, vertical: 6),
          ),
        ],
      ),
    );
    return doc.save();
  }

  // ════════════════════════════════════════
  //  حفظ / مشاركة / طباعة
  // ════════════════════════════════════════
  /// يفتح حوار الطباعة/المعاينة (يعمل أيضاً كحفظ PDF)
  Future<void> printOrPreview(Uint8List bytes, {String? name}) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name ?? 'document.pdf',
    );
  }

  /// يحفظ الملف ويفتح حوار المشاركة
  Future<void> shareBytes(Uint8List bytes, {String? name}) async {
    final dir = await getTemporaryDirectory();
    final filename = (name ?? 'document') + '.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], subject: name);
  }

  // ════════════════════════════════════════
  //  أقسام مساعدة لبناء الفاتورة
  // ════════════════════════════════════════
  pw.Widget _header(String brand, Uint8List? logo, String qrData,
      Map<String, dynamic> inv) {
    final accent = PdfColor.fromInt(_branding.primaryColorValue.value);
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: accent,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null)
            pw.ClipRRect(
              horizontalRadius: 6,
              verticalRadius: 6,
              child: pw.Image(pw.MemoryImage(logo), width: 56, height: 56,
                  fit: pw.BoxFit.cover),
            )
          else
            pw.Container(
              width: 56,
              height: 56,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text('Logo',
                  style: const pw.TextStyle(color: PdfColors.grey600)),
            ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(brand,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                if (_branding.companySlogan.value.isNotEmpty)
                  pw.Text(_branding.companySlogan.value,
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 9)),
                if (_branding.companyAddress.value.isNotEmpty)
                  pw.Text(_branding.companyAddress.value,
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 9)),
                if (_branding.companyPhone.value.isNotEmpty)
                  pw.Text('هاتف: ${_branding.companyPhone.value}',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 9)),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 56,
              height: 56,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _customerBlock(Map<String, dynamic> inv) {
    final invNum = inv['invoiceNumber'] ?? inv['id'] ?? '';
    final date = inv['date'] ?? inv['createdAt'] ?? '';
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('بيانات العميل',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                _kv('الاسم', inv['customerName']?.toString() ?? '-'),
                if ((inv['storeName'] ?? '').toString().isNotEmpty)
                  _kv('المتجر', inv['storeName'].toString()),
                if ((inv['phone'] ?? '').toString().isNotEmpty)
                  _kv('الهاتف', inv['phone'].toString()),
                if ((inv['address'] ?? '').toString().isNotEmpty)
                  _kv('العنوان', inv['address'].toString()),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('بيانات الفاتورة',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _kv('رقم الفاتورة', '#$invNum'),
              _kv('التاريخ', date.toString()),
              if ((inv['status'] ?? '').toString().isNotEmpty)
                _kv('الحالة', inv['status'].toString()),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
        child: pw.Row(
          children: [
            pw.Text('$k: ',
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(
              child: pw.Text(v, style: const pw.TextStyle(fontSize: 9)),
            ),
          ],
        ),
      );

  pw.Widget _itemsTable(List items) {
    final accent = PdfColor.fromInt(_branding.primaryColorValue.value);
    final rows = <List<String>>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i] as Map<String, dynamic>;
      final qty = (it['quantity'] ?? 0).toString();
      final unit = (it['unit'] ?? '').toString();
      final price = (it['price'] ?? it['unitPrice'] ?? 0).toString();
      final total = (it['total'] ?? it['lineTotal'] ?? 0).toString();
      rows.add([
        '${i + 1}',
        (it['name'] ?? it['productName'] ?? '').toString(),
        qty,
        unit,
        price,
        total,
      ]);
    }
    return pw.Table.fromTextArray(
      headers: const ['#', 'الصنف', 'الكمية', 'الوحدة', 'السعر', 'المجموع'],
      data: rows,
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(
          color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: pw.BoxDecoration(color: accent),
      cellStyle: const pw.TextStyle(fontSize: 9.5),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(28),
        1: pw.FlexColumnWidth(3),
        2: pw.FixedColumnWidth(45),
        3: pw.FixedColumnWidth(50),
        4: pw.FixedColumnWidth(60),
        5: pw.FixedColumnWidth(70),
      },
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    );
  }

  pw.Widget _totalsBlock(Map<String, dynamic> inv) {
    final accent = PdfColor.fromInt(_branding.primaryColorValue.value);
    final subtotal = (inv['subtotal'] ?? inv['totalAmount'] ?? 0).toString();
    final discount = (inv['discount'] ?? 0).toString();
    final total = (inv['total'] ?? inv['totalAmount'] ?? 0).toString();
    final paid = (inv['paid'] ?? inv['paidAmount'] ?? 0).toString();
    final remaining = (inv['remaining'] ?? '').toString();

    pw.Widget row(String k, String v, {bool bold = false, PdfColor? color}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(k,
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight:
                          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: color)),
              pw.Text(v,
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight:
                          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: color)),
            ],
          ),
        );

    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Container(
        width: 240,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            row('المجموع الجزئي', subtotal),
            row('الخصم', discount),
            pw.Divider(thickness: 0.5),
            row('الإجمالي', total, bold: true, color: accent),
            row('المدفوع', paid),
            if (remaining.isNotEmpty)
              row('المتبقي', remaining,
                  bold: true, color: PdfColors.red700),
          ],
        ),
      ),
    );
  }

  pw.Widget _notesBlock(String notes) => pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.amber50,
          border: pw.Border.all(color: PdfColors.amber200, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ملاحظات: ',
                style: pw.TextStyle(
                    fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(
              child: pw.Text(notes, style: const pw.TextStyle(fontSize: 9.5)),
            ),
          ],
        ),
      );

  pw.Widget _footer(String brand) => pw.Center(
        child: pw.Text(
          'تم الإنشاء بواسطة $brand • ${DateTime.now().toIso8601String().substring(0, 16).replaceAll('T', ' ')}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      );

  // ── أقسام مساعدة للتقرير ──
  pw.Widget _reportHeader(
      String brand, Uint8List? logo, String title, String? subtitle) {
    final accent = PdfColor.fromInt(_branding.primaryColorValue.value);
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null)
          pw.Image(pw.MemoryImage(logo), width: 36, height: 36),
        if (logo != null) pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(brand,
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: accent)),
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              if (subtitle != null && subtitle.isNotEmpty)
                pw.Text(subtitle,
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.Text(
          DateTime.now().toIso8601String().substring(0, 10),
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _summaryBox(Map<String, String> summary) {
    final accent = PdfColor.fromInt(_branding.primaryColorValue.value);
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(
            _branding.primaryColorValue.value & 0x00FFFFFF | 0x14000000),
        border: pw.Border.all(color: accent, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Wrap(
        spacing: 16,
        runSpacing: 6,
        children: summary.entries
            .map((e) => pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text('${e.key}: ',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: accent)),
                    pw.Text(e.value,
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ))
            .toList(),
      ),
    );
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
