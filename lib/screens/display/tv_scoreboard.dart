import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/match_model.dart';
import '../../models/score_sheet_model.dart';
import '../../utils/app_styles.dart';
import '../../utils/format_utils.dart';
import '../../services/pdf_service.dart'; // Import Service PDF

class TvScoreboardScreen extends StatefulWidget {
  final String matchId;
  const TvScoreboardScreen({super.key, required this.matchId});

  @override
  State<TvScoreboardScreen> createState() => _TvScoreboardScreenState();
}

class _TvScoreboardScreenState extends State<TvScoreboardScreen> {
  final _dbRef = FirebaseDatabase.instance.refFromURL(
      'https://kurash-usul-scoring-default-rtdb.asia-southeast1.firebasedatabase.app');

  Timer? _localTimer;
  String _timeDisplay = "00:00";
  Color _timeColor = AppColors.textLight;
  bool _showOvertimeLabel = false;
  int _lastKnownStartTime = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _startUiUpdater();
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }

  void _startUiUpdater() {
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning) {
        _updateTimerLogic();
      }
    });
  }

  void _updateTimerLogic() {
    if (_lastKnownStartTime == 0) return;

    int now = DateTime.now().millisecondsSinceEpoch;
    int diffSeconds = (now - _lastKnownStartTime) ~/ 1000;
    if (diffSeconds < 0) {
      diffSeconds = 0;
    }

    int m = diffSeconds ~/ 60;
    int s = diffSeconds % 60;
    String timeStr =
        "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";

    Color newColor = AppColors.textLight;
    bool showOver = false;

    // Logika Warna (Kuning kedip 115-120, Merah > 120)
    if (diffSeconds >= 115 && diffSeconds <= 120) {
      newColor = (diffSeconds % 2 == 0) ? Colors.yellow : AppColors.textLight;
    } else if (diffSeconds > 120) {
      newColor = Colors.red;
      showOver = true;
      _applyPenaltyAutomatically();
    }

    if (mounted) {
      setState(() {
        _timeDisplay = timeStr;
        _timeColor = newColor;
        _showOvertimeLabel = showOver;
      });
    }
  }

  bool _hasAppliedPenalty = false;
  void _applyPenaltyAutomatically() {
    if (_hasAppliedPenalty) return;
    _hasAppliedPenalty = true;
    _dbRef.child('matches/${widget.matchId}/is_time_over').set(true);
  }

  // --- FUNGSI TOMBOL ---

  void _onStartPressed() {
    // Set waktu mulai baru di database
    int now = DateTime.now().millisecondsSinceEpoch;
    _dbRef.child('matches/${widget.matchId}/start_time').set(now);
    _dbRef.child('matches/${widget.matchId}/is_time_over').set(false);

    setState(() {
      _isTimerRunning = true;
      _hasAppliedPenalty = false;
    });
  }

  void _onStopPressed() {
    // HANYA JEDA VISUAL (Tidak reset ke 00:00)
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _onSavePressed(MatchModel match, ScoreSheet? j1, ScoreSheet? j2,
      ScoreSheet? j3, double total) async {
    // 1. Simpan Waktu Terakhir ke Firebase
    await _dbRef
        .child('matches/${widget.matchId}')
        .update({'duration_string': _timeDisplay, 'status': 'finished'});

    if (!mounted) return;

    // 2. Tampilkan Popup Pilihan
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.emerald),
                  SizedBox(width: 10),
                  Text("Pertandingan Selesai"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Waktu akhir: $_timeDisplay"),
                  const SizedBox(height: 5),
                  const Text("Data berhasil disimpan. Cetak hasil sekarang?"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text("Nanti Saja",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.steelBlue,
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.print),
                  label: const Text("Cetak PDF"),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Update duration di objek match lokal untuk diprint
                    match.durationString = _timeDisplay;
                    PdfService().printMatchResult(match, j1, j2, j3, total);
                  },
                )
              ],
            ));
  }

  void _onResetTimer() {
    // Tombol Reset tersembunyi/kecil untuk mengembalikan ke 00:00
    setState(() {
      _timeDisplay = "00:00";
      _timeColor = AppColors.textLight;
      _showOvertimeLabel = false;
      _isTimerRunning = false;
      _hasAppliedPenalty = false;
    });
    _dbRef.child('matches/${widget.matchId}/start_time').remove();
    _dbRef.child('matches/${widget.matchId}/is_time_over').set(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTv,
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("OPERATOR CONTROL",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),

            // TOMBOL RESET (Kecil di kiri)
            IconButton(
              onPressed: _onResetTimer,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              tooltip: "Reset Timer ke 00:00",
            ),

            // GRUP TOMBOL UTAMA
            StreamBuilder<DatabaseEvent>(
                stream: _dbRef.child('matches/${widget.matchId}').onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const SizedBox();
                  }
                  final data =
                      jsonDecode(jsonEncode(snapshot.data!.snapshot.value));
                  final match = MatchModel.fromJson(data);

                  ScoreSheet? j1, j2, j3;
                  if (data['scores'] != null) {
                    if (data['scores']['judge_1'] != null) {
                      j1 = ScoreSheet.fromJson(data['scores']['judge_1']);
                    }
                    if (data['scores']['judge_2'] != null) {
                      j2 = ScoreSheet.fromJson(data['scores']['judge_2']);
                    }
                    if (data['scores']['judge_3'] != null) {
                      j3 = ScoreSheet.fromJson(data['scores']['judge_3']);
                    }
                  }

                  double grandTotal = (j1?.totalScore ?? 0) +
                      (j2?.totalScore ?? 0) +
                      (j3?.totalScore ?? 0);
                  if (data['is_time_over'] == true) {
                    grandTotal -= 1;
                  }

                  return Row(
                    children: [
                      // TOMBOL START
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12)),
                        onPressed: _onStartPressed,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("START"),
                      ),
                      const SizedBox(width: 15),

                      // TOMBOL STOP (PAUSE)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12)),
                        onPressed: _onStopPressed,
                        icon: const Icon(Icons.pause),
                        label: const Text("STOP"),
                      ),
                      const SizedBox(width: 15),

                      // TOMBOL SIMPAN & SELESAI
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.steelBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12)),
                        onPressed: () =>
                            _onSavePressed(match, j1, j2, j3, grandTotal),
                        icon: const Icon(Icons.save),
                        label: const Text("SIMPAN & CETAK"),
                      ),
                    ],
                  );
                })
          ],
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _dbRef.child('matches/${widget.matchId}').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Error Koneksi",
                    style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = jsonDecode(jsonEncode(snapshot.data!.snapshot.value));
          final match = MatchModel.fromJson(data);

          if (data['start_time'] != null) {
            _lastKnownStartTime = data['start_time'];
          }

          bool globalTimePenalty = data['is_time_over'] ?? false;

          ScoreSheet? j1, j2, j3;
          if (data['scores'] != null) {
            if (data['scores']['judge_1'] != null) {
              j1 = ScoreSheet.fromJson(data['scores']['judge_1']);
            }
            if (data['scores']['judge_2'] != null) {
              j2 = ScoreSheet.fromJson(data['scores']['judge_2']);
            }
            if (data['scores']['judge_3'] != null) {
              j3 = ScoreSheet.fromJson(data['scores']['judge_3']);
            }
          }

          double grandTotal = 0;
          if (j1 != null) {
            grandTotal += j1.totalScore;
          }
          if (j2 != null) {
            grandTotal += j2.totalScore;
          }
          if (j3 != null) {
            grandTotal += j3.totalScore;
          }
          if (globalTimePenalty) {
            grandTotal -= 1;
          }

          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.darkGrey,
                      AppColors.steelBlue.withValues(alpha: 0.3)
                    ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    border: const Border(
                        bottom:
                            BorderSide(color: AppColors.emerald, width: 2))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.emerald),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(match.category,
                          style: const TextStyle(
                              color: AppColors.emerald,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${FormatUtils.abbreviateName(match.participant1)} & ${FormatUtils.abbreviateName(match.participant2)}",
                            style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                height: 1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.shield,
                                  color: AppColors.steelBlue, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "KONTINGEN ${match.region}".toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.steelBlue,
                                    fontSize: 20,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_timeDisplay,
                            style: TextStyle(
                                color: _timeColor,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                        if (_showOvertimeLabel || globalTimePenalty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text("PENALTI -1",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          )
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: _JudgeCard(
                              judgeIndex: 1,
                              title: "JURI 1 (SENI)",
                              score: j1,
                              accent: AppColors.steelBlue)),
                      const SizedBox(width: 8),
                      Expanded(
                          flex: 3,
                          child: _JudgeCard(
                              judgeIndex: 2,
                              title: "JURI 2 (TEKNIK)",
                              score: j2,
                              accent: AppColors.emerald)),
                      const SizedBox(width: 8),
                      Expanded(
                          flex: 3,
                          child: _JudgeCard(
                              judgeIndex: 3,
                              title: "JURI 3 (JATUHAN)",
                              score: j3,
                              accent: AppColors.lightMint)),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardTv,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.emerald.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("TOTAL SKOR",
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 24,
                                      letterSpacing: 2)),
                              const SizedBox(height: 10),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  grandTotal.toStringAsFixed(0),
                                  style: const TextStyle(
                                      color: AppColors.emerald,
                                      fontSize: 180,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JudgeCard extends StatelessWidget {
  final int judgeIndex;
  final String title;
  final ScoreSheet? score;
  final Color accent;

  const _JudgeCard(
      {required this.judgeIndex,
      required this.title,
      required this.score,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Container(
        decoration: BoxDecoration(
            color: AppColors.cardTv, borderRadius: BorderRadius.circular(15)),
        child: const Center(
            child:
                Text("Menunggu...", style: TextStyle(color: Colors.white30))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardTv,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: accent),
                borderRadius: BorderRadius.circular(20)),
            child: Text(title,
                style: TextStyle(
                    color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          Expanded(child: _buildJudgeContent()),
          Divider(color: accent.withValues(alpha: 0.3), thickness: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
                color: Colors.black26, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                const Text("SUB-TOTAL",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                Text(
                  score!.totalScore.toStringAsFixed(0),
                  style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 56,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJudgeContent() {
    if (judgeIndex == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _rowDisplay("Kerapihan", score!.neatnessScore.toString(), accent),
          const SizedBox(height: 15),
          _rowDisplay("Ekspresi", score!.expressionScore.toString(), accent),
        ],
      );
    } else {
      bool isTechnique = judgeIndex == 2;
      return ListView.separated(
        itemCount: score!.techniques.length,
        separatorBuilder: (ctx, i) =>
            const Divider(height: 8, color: Colors.white10),
        itemBuilder: (ctx, i) {
          final t = score!.techniques[i];
          int val = isTechnique ? t.technicalScore : t.fallScore;
          return _miniRow(i + 1, t.name, val, accent);
        },
      );
    }
  }

  Widget _rowDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 50, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _miniRow(int no, String name, int score, Color scoreColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
              width: 25,
              child: Text("$no.",
                  style: const TextStyle(color: Colors.grey, fontSize: 16))),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis)),
          Text(score.toString(),
              style: TextStyle(
                  color: score > 0 ? scoreColor : Colors.white30,
                  fontWeight: FontWeight.bold,
                  fontSize: 28)),
        ],
      ),
    );
  }
}
