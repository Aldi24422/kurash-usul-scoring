class AppConstants {
  // --- Aturan Nilai Penampilan ---
  static const int maxNeatnessScore = 10; // Kerapihan
  static const int maxExpressionScore = 5; // Ekspresi

  // --- Aturan Penalti ---
  static const double timePenaltyValue = -1.0; // Dikurangi 1 poin

  // --- Daftar 8 Teknik Kurash Usul ---
  // id: kode unik, name: nama teknik, max_tech: batas nilai teknik, max_fall: batas nilai jatuhan
  static const List<Map<String, dynamic>> techniquesList = [
    {
      "id": "t1",
      "name": "Yonbosh Belbog",
      "max_tech": 4,
      "max_fall": 6,
    },
    {
      "id": "t2",
      "name": "Ayiq Quchoq",
      "max_tech": 6,
      "max_fall": 6,
    },
    {
      "id": "t3",
      "name": "Ichki Cheel",
      "max_tech": 5,
      "max_fall": 4,
    },
    {
      "id": "t4",
      "name": "Yonga Chalish",
      "max_tech": 6,
      "max_fall": 5,
    },
    {
      "id": "t5",
      "name": "Ichki Yuklama",
      "max_tech": 4,
      "max_fall": 4,
    },
    {
      "id": "t6",
      "name": "Yelka Qoldan",
      "max_tech": 5,
      "max_fall": 4,
    },
    {
      "id": "t7",
      "name": "Qarshi Usul Hatlap",
      "max_tech": 6,
      "max_fall": 4,
    },
    {
      "id": "t8",
      "name": "Jazzo",
      "max_tech": 6,
      "max_fall": 5,
    },
  ];
}