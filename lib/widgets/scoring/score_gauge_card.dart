import 'package:flutter/material.dart';

/// Widget kartu skor besar bergaya gauge/speedometer.
/// Digunakan oleh Juri 1 (Panel Seni) untuk menampilkan Kerapihan & Ekspresi.
class ScoreGaugeCard extends StatefulWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color accentColor;
  final Color backgroundColor;
  final ValueChanged<double> onChanged;

  const ScoreGaugeCard({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.accentColor,
    this.backgroundColor = Colors.white,
    required this.onChanged,
  });

  @override
  State<ScoreGaugeCard> createState() => _ScoreGaugeCardState();
}

class _ScoreGaugeCardState extends State<ScoreGaugeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant ScoreGaugeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.maxValue > 0
        ? widget.value / widget.maxValue
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.backgroundColor,
            widget.accentColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          children: [
            // --- HEADER: Label ---
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: widget.accentColor,
              ),
            ),

            const SizedBox(height: 20),

            // --- GAUGE: Angka Besar di Lingkaran ---
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.accentColor.withValues(alpha: 0.08),
                      widget.accentColor.withValues(alpha: 0.20),
                    ],
                  ),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.value.toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: widget.accentColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      "/ ${widget.maxValue}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- PROGRESS BAR visual ---
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: widget.accentColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
              ),
            ),

            const SizedBox(height: 12),

            // --- SLIDER ---
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: widget.accentColor,
                inactiveTrackColor: widget.accentColor.withValues(alpha: 0.15),
                thumbColor: widget.accentColor,
                overlayColor: widget.accentColor.withValues(alpha: 0.15),
                trackHeight: 8.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 14.0,
                  elevation: 4,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                valueIndicatorColor: widget.accentColor,
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                showValueIndicator: ShowValueIndicator.onDrag,
              ),
              child: Slider(
                value: widget.value.toDouble(),
                min: 0,
                max: widget.maxValue.toDouble(),
                divisions: widget.maxValue,
                label: widget.value.toString(),
                onChanged: widget.onChanged,
              ),
            ),

            // --- MIN / MAX labels ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("0",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400)),
                  Text("${widget.maxValue}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
