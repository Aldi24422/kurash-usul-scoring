import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scoring_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_styles.dart';
import '../../widgets/scoring/technique_row.dart';

/// Panel penilaian khusus Juri 3 (JATUHAN).
/// Menilai aspek jatuhan dari 8 gerakan Kurash Usul.
/// Tampilan: 8 slider card dengan warna Amber/Warm Orange.
class Judge3FallPanel extends StatelessWidget {
  const Judge3FallPanel({super.key});

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
                    AppColors.judge3.withValues(alpha: 0.08),
                    AppColors.judge3.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.judge3.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PANEL PENILAIAN JATUHAN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.judge3,
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
                color: AppColors.judge3.withValues(alpha: 0.06),
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
                        "Total Jatuhan: ",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        "${score.techniques.fold<int>(0, (sum, t) => sum + t.fallScore)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.judge3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- 8 Technique Sliders (Fall scores) ---
            ...List.generate(score.techniques.length, (index) {
              final techData = score.techniques[index];
              final rule = AppConstants.techniquesList[index];

              return TechniqueRow(
                index: index,
                technique: techData,
                maxTech: rule['max_tech'],
                maxFall: rule['max_fall'],
                enableTechInput: false,
                enableFallInput: true,
                accentColor: AppColors.judge3,
                cardColor: AppColors.judge3Light,
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
