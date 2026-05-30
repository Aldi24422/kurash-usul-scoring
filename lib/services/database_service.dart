import 'package:firebase_database/firebase_database.dart';
import '../models/match_model.dart';
import '../models/score_sheet_model.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // 1. Simpan Pertandingan Baru
  Future<void> createMatch(MatchModel match) async {
    await _db.child('matches/${match.id}').set(match.toJson());
    
    // Siapkan slot kosong untuk 3 Juri
    await _initializeJudges(match.id);
  }

  // 2. Siapkan Slot Nilai Kosong untuk Juri 1, 2, dan 3
  Future<void> _initializeJudges(String matchId) async {
    List<String> judges = ['judge_1', 'judge_2', 'judge_3'];
    
    for (var judgeId in judges) {
      ScoreSheet emptySheet = ScoreSheet.initial(judgeId);
      await _db
          .child('matches/$matchId/scores/$judgeId')
          .set(emptySheet.toJson());
    }
  }

  // 3. Set Status Pertandingan (Waiting -> Live -> Finished)
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _db.child('matches/$matchId').update({'status': status});
  }

  // 4. Set Pertandingan Aktif (Untuk ditampilkan di TV)
  Future<void> setActiveMatch(String matchId) async {
    await _db.child('active_match').set(matchId);
  }
}