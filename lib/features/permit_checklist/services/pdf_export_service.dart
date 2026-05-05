import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/models/checklist_progress_model.dart';
import '../domain/models/permit_item_model.dart';
import '../domain/models/user_checklist_model.dart';

class PdfExportService {
  static Future<void> exportChecklist({
    required UserChecklist checklist,
    required List<PermitItem> items,
    required List<ChecklistProgress> progress,
  }) async {
    final progressMap = {for (final p in progress) p.itemId: p.status};

    await Printing.layoutPdf(
      onLayout: (format) => _buildPdf(
        format: format,
        checklist: checklist,
        items: items,
        progressMap: progressMap,
      ),
      name: '${checklist.projectName}_permit_checklist.pdf',
    );
  }

  static Future<Uint8List> _buildPdf({
    required PdfPageFormat format,
    required UserChecklist checklist,
    required List<PermitItem> items,
    required Map<String, String> progressMap,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final navyColor = const PdfColor.fromInt(0xFF1B2A4A);
    final goldColor = const PdfColor.fromInt(0xFFC9A84C);
    final borderColor = const PdfColor.fromInt(0xFFE5E7EB);
    final successColor = const PdfColor.fromInt(0xFF22C55E);
    final warningColor = const PdfColor.fromInt(0xFFF59E0B);
    final greyColor = const PdfColor.fromInt(0xFF9CA3AF);

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'OneIP — Checklist Thủ Tục',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 18,
                    color: navyColor,
                  ),
                ),
                pw.Text(
                  'Ngày xuất: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: greyColor,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: goldColor, thickness: 1.5),
            pw.SizedBox(height: 8),
            pw.Text(
              checklist.projectName,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: navyColor,
              ),
            ),
            if (checklist.companyName != null)
              pw.Text(
                checklist.companyName!,
                style: pw.TextStyle(font: font, fontSize: 11, color: greyColor),
              ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tiến độ: ${checklist.completedItems}/${checklist.totalItems} bước hoàn thành',
              style: pw.TextStyle(font: font, fontSize: 11, color: greyColor),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.4),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(0.8),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: navyColor),
                children: [
                  '#',
                  'Thủ tục',
                  'Cơ quan thực hiện',
                  'Thời gian',
                  'Trạng thái',
                ].map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 5),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 9, color: PdfColors.white),
                  ),
                )).toList(),
              ),
              ...items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final status = progressMap[item.id] ?? 'pending';
                final isEven = i.isEven;
                final bg = isEven ? PdfColors.white : const PdfColor.fromInt(0xFFF9FAFB);

                PdfColor statusColor;
                String statusText;
                switch (status) {
                  case 'done':
                    statusColor = successColor;
                    statusText = 'Xong';
                  case 'in_progress':
                    statusColor = warningColor;
                    statusText = 'Đang làm';
                  case 'skipped':
                    statusColor = greyColor;
                    statusText = 'Bỏ qua';
                  default:
                    statusColor = greyColor;
                    statusText = 'Chưa làm';
                }

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        '${i + 1}',
                        style: pw.TextStyle(font: font, fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        item.title,
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        item.authority ?? '—',
                        style: pw.TextStyle(
                            font: font, fontSize: 8, color: greyColor),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        '~${item.estimatedDays}N',
                        style: pw.TextStyle(font: font, fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        statusText,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: statusColor),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Được tạo bởi OneIP — Công cụ quản lý thủ tục KCN Việt Nam',
            style: pw.TextStyle(font: font, fontSize: 8, color: greyColor),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return Uint8List.fromList(await doc.save());
  }
}
