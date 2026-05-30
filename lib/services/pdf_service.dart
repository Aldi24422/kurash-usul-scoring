import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/match_model.dart';
import '../models/score_sheet_model.dart';

class PdfService {
  Future<void> printMatchResult(MatchModel match, ScoreSheet? j1,
      ScoreSheet? j2, ScoreSheet? j3, double totalScore) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Header(
                level: 0,
                child: pw.Center(
                  child: pw.Column(children: [
                    pw.Text("HASIL PENILAIAN KURASH UZUL",
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text("OFFICIAL MATCH SCORE SHEET",
                        style: pw.TextStyle(
                            fontSize: 12, fontStyle: pw.FontStyle.italic)),
                  ]),
                ),
              ),
              pw.SizedBox(height: 20),

              // INFO PERTANDINGAN
              pw.Row(children: [
                pw.Expanded(child: _buildInfoColumn("Match ID", match.id)),
                pw.Expanded(
                    child: _buildInfoColumn("Kategori",
                        match.category == 'PA' ? "PUTRA" : "PUTRI")),
                pw.Expanded(
                    child: _buildInfoColumn("Durasi", match.durationString)),
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Expanded(child: _buildInfoColumn("Kontingen", match.region)),
                pw.Expanded(
                    flex: 2,
                    child: _buildInfoColumn("Atlet",
                        "${match.participant1} & ${match.participant2}")),
              ]),

              pw.Divider(),
              pw.SizedBox(height: 10),

              // TABEL NILAI
              pw.Table(border: pw.TableBorder.all(), columnWidths: {
                0: const pw.FlexColumnWidth(3), // Nama Teknik
                1: const pw.FlexColumnWidth(1), // Juri 1
                2: const pw.FlexColumnWidth(1), // Juri 2
                3: const pw.FlexColumnWidth(1), // Juri 3
              }, children: [
                // Header Tabel
                pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _cell("KRITERIA / TEKNIK", isBold: true),
                      _cell("JURI 1\n(Seni)",
                          isBold: true, align: pw.TextAlign.center),
                      _cell("JURI 2\n(Teknik)",
                          isBold: true, align: pw.TextAlign.center),
                      _cell("JURI 3\n(Jatuhan)",
                          isBold: true, align: pw.TextAlign.center),
                    ]),

                // Baris Penampilan
                pw.TableRow(children: [
                  _cell("1. Kerapihan & Etika"),
                  _cell("${j1?.neatnessScore ?? 0}",
                      align: pw.TextAlign.center),
                  _cell("-", align: pw.TextAlign.center),
                  _cell("-", align: pw.TextAlign.center),
                ]),
                pw.TableRow(children: [
                  _cell("2. Ekspresi & Penjiwaan"),
                  _cell("${j1?.expressionScore ?? 0}",
                      align: pw.TextAlign.center),
                  _cell("-", align: pw.TextAlign.center),
                  _cell("-", align: pw.TextAlign.center),
                ]),

                // Loop Teknik
                if (j2 != null)
                  ...List.generate(j2.techniques.length, (index) {
                    var t2 = j2.techniques[index];
                    var t3 = j3?.techniques[
                        index]; // Ambil data teknik juri 3 yg indexnya sama
                    return pw.TableRow(children: [
                      _cell("${index + 3}. ${t2.name}"),
                      _cell("-", align: pw.TextAlign.center),
                      _cell("${t2.technicalScore}", align: pw.TextAlign.center),
                      _cell("${t3?.fallScore ?? 0}",
                          align: pw.TextAlign.center),
                    ]);
                  }),
              ]),

              pw.SizedBox(height: 20),

              // TOTAL SKOR
              pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("TOTAL SKOR AKHIR: ",
                            style: pw.TextStyle(
                                fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(),
                              color: PdfColors.green100),
                          child: pw.Text(totalScore.toStringAsFixed(0),
                              style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold)),
                        )
                      ])),

              pw.Spacer(),

              // TANDA TANGAN
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _sigBox("Juri 1 (Seni)"),
                    _sigBox("Juri 2 (Teknik)"),
                    _sigBox("Juri 3 (Jatuhan)"),
                    _sigBox("Ketua Pertandingan"),
                  ]),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildInfoColumn(String label, String value) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.Text(value,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 5),
        ]);
  }

  pw.Widget _cell(String text,
      {bool isBold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text,
            textAlign: align,
            style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: 10)));
  }

  pw.Widget _sigBox(String title) {
    return pw.Column(children: [
      pw.SizedBox(height: 40),
      pw.Container(width: 80, height: 1, color: PdfColors.black),
      pw.SizedBox(height: 4),
      pw.Text(title, style: const pw.TextStyle(fontSize: 9)),
    ]);
  }
}
