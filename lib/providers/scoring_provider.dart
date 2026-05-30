import 'dart:async';
import 'dart:convert'; // Tambahan untuk jsonEncode jika perlu debugging
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/match_model.dart';
import '../models/score_sheet_model.dart';

class ScoringProvider with ChangeNotifier {
  // Gunakan URL Database Anda yang spesifik (Region Singapore)
  final _db = FirebaseDatabase.instance.refFromURL(
    'https://kurash-usul-scoring-default-rtdb.asia-southeast1.firebasedatabase.app'
  );
  
  MatchModel? currentMatch;
  ScoreSheet? currentScoreSheet;
  String? currentJudgeId;
  bool isLoading = false;
  
  // Variabel untuk menyimpan pesan error terakhir
  String errorMessage = "";

  // 1. Juri Masuk ke Pertandingan (Login)
  Future<bool> joinMatch(String matchId, String judgeId) async {
    try {
      isLoading = true;
      errorMessage = ""; // Reset error
      notifyListeners();

      debugPrint("Mencari Match ID: $matchId di database...");

      // Cek apakah pertandingan ada?
      final snapshot = await _db.child('matches/$matchId').get();

      if (!snapshot.exists) {
        isLoading = false;
        errorMessage = "Data ID $matchId tidak ditemukan di Database.";
        notifyListeners();
        return false;
      }

      debugPrint("Data ditemukan: ${snapshot.value}");

      // --- PERBAIKAN UTAMA: CARA KONVERSI MAP ---
      // Kita konversi paksa data dari Firebase menjadi Map yang aman
      final data = jsonDecode(jsonEncode(snapshot.value)); 
      
      currentMatch = MatchModel.fromJson(data);
      currentJudgeId = judgeId;

      // Ambil lembar nilai juri tersebut
      final scoreSnap = await _db.child('matches/$matchId/scores/$judgeId').get();
      if (scoreSnap.exists) {
        final scoreData = jsonDecode(jsonEncode(scoreSnap.value));
        currentScoreSheet = ScoreSheet.fromJson(scoreData);
      } else {
        currentScoreSheet = ScoreSheet.initial(judgeId);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("CRITICAL ERROR: $e"); // Cek Console untuk error detail
      isLoading = false;
      errorMessage = "Error Sistem: $e"; // Tampilkan error ke layar
      notifyListeners();
      return false;
    }
  }

  // 2. Fungsi Update Nilai
  void updateScore() {
    if (currentMatch == null || currentJudgeId == null || currentScoreSheet == null) return;

    _db.child('matches/${currentMatch!.id}/scores/$currentJudgeId')
       .set(currentScoreSheet!.toJson());
    
    notifyListeners();
  }

  // Helpers
  void setNeatness(double val) {
    currentScoreSheet!.neatnessScore = val.toInt();
    updateScore();
  }

  void setExpression(double val) {
    currentScoreSheet!.expressionScore = val.toInt();
    updateScore();
  }
  
  void setTechniqueScore(int index, int techVal, int fallVal) {
    currentScoreSheet!.techniques[index].technicalScore = techVal;
    currentScoreSheet!.techniques[index].fallScore = fallVal;
    updateScore();
  }

  void setTimePenalty(bool value) {
    currentScoreSheet!.isTimeOver = value;
    updateScore();
  }
}