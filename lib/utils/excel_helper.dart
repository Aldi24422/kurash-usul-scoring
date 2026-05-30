import 'dart:math'; // Tambahan untuk Random
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../models/match_model.dart';

class ExcelHelper {
  /// Membaca bytes file Excel dan mengubahnya jadi `List<MatchModel>`
  static Future<List<MatchModel>> parseMatchExcel(Uint8List bytes) async {
    List<MatchModel> matches = [];
    final random = Random(); // Untuk generate angka acak

    try {
      var excel = Excel.decodeBytes(bytes);

      // Ambil sheet pertama
      var table = excel.tables[excel.tables.keys.first];

      if (table != null) {
        for (var i = 1; i < table.maxRows; i++) {
          var row = table.rows[i];

          // Pastikan baris tidak kosong
          if (row.isEmpty) continue;

          // Ambil value cell dengan aman
          String getCellValue(int colIndex) {
            if (colIndex >= row.length) return "";
            var value = row[colIndex]?.value;
            return value?.toString().trim() ?? "";
          }

          String idRaw = getCellValue(0);
          String p1 = getCellValue(1);
          String p2 = getCellValue(2);
          String cat = getCellValue(3).toUpperCase();
          String region = getCellValue(4).toUpperCase();

          // Validasi minimal: Nama peserta harus ada
          if (p1.isNotEmpty && p2.isNotEmpty) {
            // Normalisasi Kategori
            String finalCat =
                cat.contains("PI") || cat.contains("PUTRI") ? "PI" : "PA";

            // LOGIKA BARU: Generate ID 3 Digit (100 - 999)
            // Jika di excel kosong, kita buatkan angka acak 3 digit
            String finalId =
                idRaw.isEmpty ? (100 + random.nextInt(900)).toString() : idRaw;

            matches.add(MatchModel(
                id: finalId,
                participant1: p1.toUpperCase(),
                participant2: p2.toUpperCase(),
                category: finalCat,
                region: region.isEmpty ? "UMUM" : region,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                status: 'pending' // Default status
                ));
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing Excel: $e");
    }

    return matches;
  }
}
