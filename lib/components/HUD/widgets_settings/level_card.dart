import 'package:flutter/material.dart';
import '../style/text_style_singleton.dart';

class LevelCard extends StatefulWidget {
  final int levelNumber;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final bool isLocked;
  final bool isCompleted;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.onTap,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    this.isLocked = false,
    this.isCompleted = false,
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

  @override
  Widget build(BuildContext context) {
    final disabledColor = Colors.grey.withOpacity(0.4);

    return GestureDetector(
      onTap: widget.isLocked ? null : widget.onTap,
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isLocked ? disabledColor : widget.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.levelNumber}',
                style: TextStyleSingleton().style.copyWith(
                  fontSize: 22,
                  color: widget.isLocked ? Colors.grey[300] : widget.textColor,
                  shadows: [
                    const Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)
                  ],
                ),
              ),
            ),
            if (widget.isLocked)
              const Icon(Icons.lock, size: 28, color: Colors.white70),
            if (widget.isCompleted)
              const Positioned(
                bottom: 4,
                right: 4,
                child: Icon(Icons.star, size: 20, color: Colors.amber),
              ),
          ],
        ),
      ),
    );
  }
}