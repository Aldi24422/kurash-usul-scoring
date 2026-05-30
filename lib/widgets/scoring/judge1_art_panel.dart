import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scoring_provider.dart';
import '../../utils/app_styles.dart';
import '../../widgets/scoring/score_gauge_card.dart';

/// Panel penilaian khusus Juri 1 (SENI).
/// Menilai 2 aspek: Kerapihan (0-10) dan Ekspresi (0-5).
/// Tampilan: 2 kartu gauge besar secara vertikal dengan warna Steel Blue.
class Judge1ArtPanel extends StatelessWidget {
  const Judge1ArtPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoringProvider>(
      builder: (context, provider, _) {
        final score = provider.currentScoreSheet;
        if (score == null) {
          return const Center(child: Text("Data belum tersedia"));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            // --- Badge identitas juri ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.judge1.withValues(alpha: 0.08),
                    AppColors.judge1.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.judge1.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PANEL PENILAIAN SENI",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.judge1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- KARTU 1: KERAPIHAN (0-10) ---
            ScoreGaugeCard(
              label: "Kerapihan",
              value: score.neatnessScore,
              maxValue: 10,
              accentColor: AppColors.judge1,
              onChanged: (val) => provider.setNeatness(val),
            ),

            const SizedBox(height: 20),

            // --- KARTU 2: EKSPRESI (0-5) ---
            ScoreGaugeCard(
              label: "Ekspresi",
              value: score.expressionScore,
              maxValue: 5,
              accentColor: const Color(0xFF1565C0), // Darker blue variant
              onChanged: (val) => provider.setExpression(val),
            ),
          ],
        );
      },
    );
  }
}
