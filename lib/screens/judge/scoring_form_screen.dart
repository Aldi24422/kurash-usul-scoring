import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scoring_provider.dart';
import '../../utils/app_styles.dart';
import '../../utils/format_utils.dart';
import '../../widgets/scoring/judge1_art_panel.dart';
import '../../widgets/scoring/judge2_tech_panel.dart';
import '../../widgets/scoring/judge3_fall_panel.dart';

class ScoringFormScreen extends StatelessWidget {
  const ScoringFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoringProvider>(
      builder: (context, provider, child) {
        var match = provider.currentMatch;
        var score = provider.currentScoreSheet;

        String judgeId = provider.currentJudgeId ?? '';
        bool isJudge1 = judgeId == 'judge_1';
        bool isJudge2 = judgeId == 'judge_2';

        if (match == null || score == null) {
          return const Scaffold(
              body: Center(child: Text("Data Error - Silakan Login Ulang")));
        }

        // Tentukan warna aksen berdasarkan juri
        Color judgeAccent = isJudge1
            ? AppColors.judge1
            : isJudge2
                ? AppColors.judge2
                : AppColors.judge3;

        String judgeNameDisplay =
            judgeId.replaceAll('judge_', 'JURI ').toUpperCase();

        String judgeRoleDisplay = isJudge1
            ? "SENI"
            : isJudge2
                ? "TEKNIK"
                : "JATUHAN";

        return Scaffold(
          appBar: AppBar(
            // Tinggi toolbar agar aman di layar kecil
            toolbarHeight: 140,
            backgroundColor: AppColors.darkGrey,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge juri dengan warna unik
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: judgeAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$judgeNameDisplay — $judgeRoleDisplay",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: judgeAccent,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Nama peserta
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${FormatUtils.abbreviateName(match.participant1)} & ${FormatUtils.abbreviateName(match.participant2)}",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  color: Colors.white),
                              maxLines: 2,
                            ),
                          ),

                          const SizedBox(height: 4),
                          Text(
                            "KONTINGEN ${match.region}".toUpperCase(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: judgeAccent,
                                letterSpacing: 0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Sub-total box dengan warna juri
                    Container(
                      height: 90,
                      width: 90,
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: judgeAccent.withValues(alpha: 0.4),
                              width: 1.5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("SUB-TOTAL",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70)),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                score.totalScore.toStringAsFixed(0),
                                style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: judgeAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // --- BOTTOM BUTTON: Selesai Menilai ---
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -5))
            ]),
            child: SafeArea(
              child: SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: judgeAccent.withValues(alpha: 0.4),
                  ),
                  icon: Icon(Icons.check_circle,
                      color: judgeAccent, size: 28),
                  label: const Text(
                    "SELESAI MENILAI",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: const Text("Selesai Menilai?"),
                              content:
                                  const Text("Data akan tersimpan otomatis."),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Batal")),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: judgeAccent,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Ya, Selesai"))
                              ],
                            ));
                  },
                ),
              ),
            ),
          ),

          // --- BODY: Panel berbeda per juri ---
          body: _buildJudgePanel(judgeId),
        );
      },
    );
  }

  /// Router: tampilkan panel yang sesuai berdasarkan judgeId
  Widget _buildJudgePanel(String judgeId) {
    switch (judgeId) {
      case 'judge_1':
        return const Judge1ArtPanel();
      case 'judge_2':
        return const Judge2TechPanel();
      case 'judge_3':
        return const Judge3FallPanel();
      default:
        return const Center(
          child: Text("Role juri tidak dikenali"),
        );
    }
  }
}
