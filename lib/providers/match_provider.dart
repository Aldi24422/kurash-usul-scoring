import 'dart:math';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/database_service.dart';

class MatchProvider with ChangeNotifier {
  final DatabaseService _service = DatabaseService();
  bool isLoading = false;

  // Fungsi membuat pertandingan
  Future<bool> createNewMatch({
    required String p1,
    required String p2,
    required String category,
    required String region,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1. Generate 3 Digit ID Unik (100 - 999)
      String uniqueId = (Random().nextInt(900) + 100).toString();

      // 2. Buat Object Model
      MatchModel newMatch = MatchModel(
        id: uniqueId,
        participant1: p1,
        participant2: p2,
        category: category,
        region: region,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'waiting', // Default status
      );

      // 3. Kirim ke Database
      await _service.createMatch(newMatch);

      // 4. Set sebagai pertandingan aktif di TV
      await _service.setActiveMatch(uniqueId);

      isLoading = false;
      notifyListeners();
      return true; // Berhasil
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Error creating match: $e");
      return false; // Gagal
    }
  }

  // --- FUNGSI BARU: IMPORT BULK ---
  Future<int> importMatches(List<MatchModel> newMatches) async {
    isLoading = true;
    notifyListeners();

    int successCount = 0;

    try {
      for (var match in newMatches) {
        // Generate ID unik jika belum ada, atau gunakan logika ID Anda
        // Di sini kita biarkan ID dari Excel atau generate baru jika kosong
        if (match.id.isEmpty) {
          match.id = (DateTime.now().millisecondsSinceEpoch % 100000)
              .toString(); // Fallback ID
        }

        await _service.createMatch(match);
        successCount++;
      }
    } catch (e) {
      debugPrint("Error importing: $e");
    }

    isLoading = false;
    notifyListeners();
    return successCount;
  }
}
