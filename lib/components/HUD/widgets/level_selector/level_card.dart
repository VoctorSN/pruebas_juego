import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../style/text_style_singleton.dart';

class LevelCard extends StatefulWidget {
  final int levelNumber;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color textColor;
  final int difficulty;
  final bool isLocked;
  final bool isCompleted;
  final int stars;
  final int duration;
  final int deaths;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
    required this.difficulty,
    this.isLocked = false,
    this.isCompleted = false,
    this.stars = 0,
    required this.duration,
    required this.deaths,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> {
  double scale = 1.0;

  void _setScale(double value) {
    setState(() {
      scale = value;
    });
  }

  Color _calculateBorderColor() {
    final int clamped = widget.difficulty.clamp(0, 10);
    final double t = clamped / 10.0;
    return Color.lerp(Colors.green, Colors.red, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final Color disabledColor = Colors.grey.withOpacity(0.4);
    final Color borderColor = _calculateBorderColor();

    final String timeText = widget.isCompleted ? '${widget.duration}' : '?';
    final String deathsText = widget.isCompleted ? '${widget.deaths}' : '?';

    return GestureDetector(
      onTap: widget.isLocked ? null : widget.onTap,
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.isLocked ? disabledColor : widget.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (!widget.isLocked) ...[
                Positioned(
                  top: 4,
                  left: 6,
                  child: Row(
                    children: [
                      Text(
                        deathsText,
                        style: TextStyleSingleton().style.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(FontAwesomeIcons.skull, size: 12, color: Colors.white),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 6,
                  child: Row(
                    children: [
                      Text(
                        timeText,
                        style: TextStyleSingleton().style.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.access_time, size: 12, color: Colors.white),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.levelNumber + 1}',
                    style: TextStyleSingleton().style.copyWith(
                      fontSize: 22,
                      color: widget.textColor,
                      shadows: const [
                        Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.star,
                        size: 14,
                        color: index < widget.stars ? Colors.amber : Colors.grey,
                      );
                    }),
                  ),
                ),
              ],
              if (widget.isLocked)
                const Center(
                  child: Icon(Icons.lock, size: 28, color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }
}