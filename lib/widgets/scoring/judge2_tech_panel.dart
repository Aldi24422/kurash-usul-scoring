import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scoring_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_styles.dart';
import '../../widgets/scoring/technique_row.dart';

/// Panel penilaian khusus Juri 2 (TEKNIK).
/// Menilai aspek teknik dari 8 gerakan Kurash Usul.
/// Tampilan: 8 slider card dengan warna Emerald Green.
class Judge2TechPanel extends StatelessWidget {
  const Judge2TechPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoringProvider>(
      builder: (context, provider, _) {
        final score = provider.currentScoreSheet;
        if (score == null) {
          return const Center(child: Text("Data belum tersedia"));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            // --- Badge identitas juri ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.judge2.withValues(alpha: 0.08),
                    AppColors.judge2.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.judge2.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PANEL PENILAIAN TEKNIK",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.judge2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // --- Summary row ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.judge2.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "8 Gerakan",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Total Teknik: ",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        "${score.techniques.fold<int>(0, (sum, t) => sum + t.technicalScore)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.judge2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- 8 Technique Sliders ---
            ...List.generate(score.techniques.length, (index) {
              final techData = score.techniques[index];
              final rule = AppConstants.techniquesList[index];

              return TechniqueRow(
                index: index,
                technique: techData,
                maxTech: rule['max_tech'],
                maxFall: rule['max_fall'],
                enableTechInput: true,
                enableFallInput: false,
                accentColor: AppColors.judge2,
                cardColor: AppColors.judge2Light,
                onUpdate: (newTech, newFall) {
                  provider.setTechniqueScore(index, newTech, newFall);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
