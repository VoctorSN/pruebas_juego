import 'package:flutter/material.dart';
import '../../../pixel_adventure.dart';
import 'level_card.dart';

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