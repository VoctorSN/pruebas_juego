import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../pixel_adventure.dart';
import '../style/text_style_singleton.dart';
import 'level_card.dart';

// TODO when you press back button, it close the menu and resume the game or go to the main menu depending on the game state
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

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: cardColor,
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 8,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: baseColor.withAlpha((0.95 * 255).toInt()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Level',
                  style: TextStyleSingleton().style.copyWith(
                    fontSize: 32,
                    color: textColor,
                    shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
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
                  style: buttonStyle,
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back, color: textColor),
                  label: Text('BACK', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
                ),
              ],
            ),
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
