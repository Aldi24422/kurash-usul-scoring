import '../utils/app_constants.dart';

// Class kecil untuk menampung nilai per satu teknik
class TechniqueScore {
  String id;
  String name;
  int technicalScore; // Nilai Teknik
  int fallScore;      // Nilai Jatuhan

  TechniqueScore({
    required this.id,
    required this.name,
    this.technicalScore = 0,
    this.fallScore = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tech': technicalScore,
    'fall': fallScore,
  };

  factory TechniqueScore.fromJson(Map<String, dynamic> json) {
    return TechniqueScore(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      technicalScore: json['tech'] ?? 0,
      fallScore: json['fall'] ?? 0,
    );
  }
}

// Class Utama Lembar Nilai
class ScoreSheet {
  String judgeId; // juri_1, juri_2, atau juri_3
  int neatnessScore;
  int expressionScore;
  bool isTimeOver; // Checkbox waktu
  List<TechniqueScore> techniques;

  ScoreSheet({
    required this.judgeId,
    this.neatnessScore = 0,
    this.expressionScore = 0,
    this.isTimeOver = false,
    required this.techniques,
  });

  // --- RUMUS TOTAL SKOR ---
  // Penampilan + Total Teknik + Total Jatuhan - Penalti
  double get totalScore {
    double total = 0;
    
    // 1. Aspek Penampilan
    total += neatnessScore;
    total += expressionScore;

    // 2. Aspek Teknik (Looping 8 teknik)
    for (var tech in techniques) {
      total += tech.technicalScore;
      total += tech.fallScore;
    }

    // 3. Penalti Waktu
    if (isTimeOver) {
      total += AppConstants.timePenaltyValue; // Kurang 1
    }

    return total;
  }

  // Membuat lembar kosong baru (Generate 8 teknik otomatis)
  factory ScoreSheet.initial(String judgeId) {
    List<TechniqueScore> initialTechs = AppConstants.techniquesList.map((data) {
      return TechniqueScore(
        id: data['id'],
        name: data['name'],
      );
    }).toList();

    return ScoreSheet(judgeId: judgeId, techniques: initialTechs);
  }

  Map<String, dynamic> toJson() {
    return {
      'judge_id': judgeId,
      'neatness': neatnessScore,
      'expression': expressionScore,
      'is_time_over': isTimeOver,
      'techniques': techniques.map((t) => t.toJson()).toList(),
    };
  }

  factory ScoreSheet.fromJson(Map<String, dynamic> json) {
    var list = json['techniques'] as List? ?? [];
    List<TechniqueScore> techList = list.map((i) => TechniqueScore.fromJson(i)).toList();

    // Jika data teknik kosong (misal baru load), generate ulang dari Constants
    if (techList.isEmpty) {
       techList = AppConstants.techniquesList.map((data) {
        return TechniqueScore(id: data['id'], name: data['name']);
      }).toList();
    }

    return ScoreSheet(
      judgeId: json['judge_id'] ?? 'unknown',
      neatnessScore: json['neatness'] ?? 0,
      expressionScore: json['expression'] ?? 0,
      isTimeOver: json['is_time_over'] ?? false,
      techniques: techList,
    );
  }
}