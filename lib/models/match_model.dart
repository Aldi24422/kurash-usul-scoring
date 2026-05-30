class MatchModel {
  String id;
  String participant1;
  String participant2;
  String category;
  String region;
  String status;
  int timestamp;
  String durationString; // FIELD BARU: Menyimpan waktu akhir

  MatchModel({
    required this.id,
    required this.participant1,
    required this.participant2,
    required this.category,
    required this.region,
    this.status = 'waiting',
    required this.timestamp,
    this.durationString = "00:00", // Default
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_1': participant1,
      'participant_2': participant2,
      'category': category,
      'region': region,
      'status': status,
      'created_at': timestamp,
      'duration_string': durationString, // Simpan ke Firebase
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? '000',
      participant1: json['participant_1'] ?? '-',
      participant2: json['participant_2'] ?? '-',
      category: json['category'] ?? '-',
      region: json['region'] ?? '-',
      status: json['status'] ?? 'waiting',
      timestamp: json['created_at'] ?? 0,
      durationString: json['duration_string'] ?? "00:00", // Ambil dari Firebase
    );
  }
}
