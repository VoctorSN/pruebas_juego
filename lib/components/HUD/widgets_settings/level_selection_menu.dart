import 'package:flutter/material.dart';

import '../../../pixel_adventure.dart';

class LevelSelectionMenu extends StatelessWidget {
  static const String id = 'level_selection_menu';

  final int totalLevels;
  final void Function(int) onLevelSelected;
  final List<int> unlockedLevels;
  final List<int> completedLevels;
  final PixelAdventure game;

  const LevelSelectionMenu({
    super.key,
    required this.game,
    required this.totalLevels,
    required this.onLevelSelected,
    this.unlockedLevels = const [],
    this.completedLevels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF212030);
    final Color cardColor = const Color(0xFF3A3750);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

    return Scaffold(
      backgroundColor: baseColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Level',
                style: TextStyle(
                  fontSize: 36,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: List.generate(totalLevels, (index) {
                  final level = index + 1;
                  final isUnlocked = unlockedLevels.contains(level);
                  final isCompleted = completedLevels.contains(level);
                  return LevelCard(
                    levelNumber: level,
                    onTap: isUnlocked ? () => onLevelSelected(level) : null,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    isLocked: !isUnlocked,
                    isCompleted: isCompleted,
                  );
                }),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onBack() {
    game.overlays.remove(LevelSelectionMenu.id);
    game.resumeEngine();
  }
}

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
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.levelNumber}',
                style: TextStyle(
                  fontSize: 24,
                  color: widget.isLocked ? Colors.grey[300] : widget.textColor,
                  fontWeight: FontWeight.bold,
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
