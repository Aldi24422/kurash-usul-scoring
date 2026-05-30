import 'package:flutter/material.dart';
import '../../models/score_sheet_model.dart';

/// Widget baris teknik berbasis Slider (bukan TextField).
/// Digunakan oleh Juri 2 (Teknik) dan Juri 3 (Jatuhan).
/// Setiap baris menampilkan: nomor + nama teknik, slider, dan badge skor.
class TechniqueRow extends StatelessWidget {
  final int index;
  final TechniqueScore technique;
  final int maxTech;
  final int maxFall;
  final bool enableTechInput;
  final bool enableFallInput;
  final Function(int tech, int fall) onUpdate;

  /// Warna aksen slider (berbeda per juri)
  final Color accentColor;

  /// Warna background kartu
  final Color cardColor;

  const TechniqueRow({
    super.key,
    required this.index,
    required this.technique,
    required this.maxTech,
    required this.maxFall,
    this.enableTechInput = true,
    this.enableFallInput = true,
    required this.onUpdate,
    this.accentColor = const Color(0xFF50D890),
    this.cardColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah ini untuk Teknik atau Jatuhan berdasarkan enable flags
    final bool showTech = enableTechInput;
    final int currentValue =
        showTech ? technique.technicalScore : technique.fallScore;
    final int maxValue = showTech ? maxTech : maxFall;
    final String scoreLabel = showTech ? "Teknik" : "Jatuhan";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: currentValue > 0
              ? accentColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: currentValue > 0
                ? accentColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Nomor + Nama + Badge Skor ---
            Row(
              children: [
                // Nomor urut
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Nama teknik
                Expanded(
                  child: Text(
                    technique.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF272727),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge skor
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentValue > 0
                        ? accentColor
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: currentValue > 0
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    "$currentValue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: currentValue > 0
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // --- Slider ---
            Row(
              children: [
                // Label max kecil
                Text(
                  "$scoreLabel (max $maxValue)",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: accentColor,
                inactiveTrackColor: accentColor.withValues(alpha: 0.12),
                thumbColor: accentColor,
                overlayColor: accentColor.withValues(alpha: 0.12),
                trackHeight: 6.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 11.0,
                  elevation: 3,
                ),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 20),
                valueIndicatorColor: accentColor,
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                showValueIndicator: ShowValueIndicator.onDrag,
              ),
              child: Slider(
                value: currentValue.toDouble(),
                min: 0,
                max: maxValue.toDouble(),
                divisions: maxValue,
                label: currentValue.toString(),
                onChanged: (val) {
                  if (showTech) {
                    onUpdate(val.toInt(), technique.fallScore);
                  } else {
                    onUpdate(technique.technicalScore, val.toInt());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
