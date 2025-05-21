import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import 'level_card.dart';

class LevelSelectionMenu extends StatefulWidget {
  static const String id = 'level_selection_menu';

  final int totalLevels;
  final void Function(int) onLevelSelected;
  final PixelAdventure game;

  const LevelSelectionMenu({
    super.key,
    required this.game,
    required this.totalLevels,
    required this.onLevelSelected,
  });

  @override
  State<LevelSelectionMenu> createState() => _LevelSelectionMenuState();
}

class _LevelSelectionMenuState extends State<LevelSelectionMenu> {
  final ScrollController _scrollController = ScrollController();

  static const double _cardSpacing = 12;
  static const double _minCardSize = 90;
  static const double _minCardsPerRow = 3;

  void scrollByRow({required bool forward, required double rowSize}) {
    final double rowHeight = rowSize + _cardSpacing;
    final double currentOffset = _scrollController.offset;
    final int currentRow = (currentOffset / rowHeight).round();

    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, double.infinity).toInt();
    final double targetOffset = targetRow * rowHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void onBack() {
    widget.game.overlays.remove(LevelSelectionMenu.id);
    widget.game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF212030);
    final Color cardColor = const Color(0xFF3A3750);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: cardColor,
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 6,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth * 0.8;
              final double maxHeight = constraints.maxHeight * 0.8;

              final double availableWidth = maxWidth - 96;
              final double calculatedCardsPerRow = (availableWidth / (_minCardSize + _cardSpacing)).floorToDouble();
              final double cardsPerRow = calculatedCardsPerRow.clamp(_minCardsPerRow, double.infinity);
              final double cardSize = (availableWidth - (_cardSpacing * (cardsPerRow - 1))) / cardsPerRow;

              return Container(
                width: maxWidth,
                height: maxHeight,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Select Level',
                      style: TextStyleSingleton().style.copyWith(
                        fontSize: 28,
                        color: textColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Wrap(
                                spacing: _cardSpacing,
                                runSpacing: _cardSpacing,
                                alignment: WrapAlignment.center,
                                children: List.generate(widget.totalLevels, (index) {
                                  final int level = index;
                                  final bool isUnlocked = widget.game.unlockedLevelIndices.contains(level);
                                  final bool isCompleted = widget.game.completedLevelIndices.contains(level);

                                  return SizedBox(
                                    height: cardSize,
                                    width: cardSize,
                                    child: LevelCard(
                                      levelNumber: level,
                                      onTap: isUnlocked ? () => widget.onLevelSelected(level) : null,
                                      cardColor: cardColor,
                                      stars: widget.game.starsPerLevel[index] ?? 0,
                                      textColor: textColor,
                                      isLocked: !isUnlocked,
                                      isCompleted: isCompleted,
                                      difficulty: widget.game.levels[index]['level'].difficulty ?? 0,
                                      deaths: widget.game.levels[index]['gameLevel'].deaths ?? 0,
                                      duration: widget.game.levels[index]['gameLevel'].time ?? 0,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildScrollButton(
                                icon: Icons.keyboard_arrow_up,
                                onPressed: () => scrollByRow(forward: false, rowSize: cardSize),
                                color: cardColor,
                                iconColor: textColor,
                                borderColor: borderColor,
                              ),
                              const SizedBox(height: 8),
                              _buildScrollButton(
                                icon: Icons.keyboard_arrow_down,
                                onPressed: () => scrollByRow(forward: true, rowSize: cardSize),
                                color: cardColor,
                                iconColor: textColor,
                                borderColor: borderColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(FontAwesomeIcons.skull, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.game.gameData?.totalDeaths ?? 0}',
                            style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: buttonStyle,
                        onPressed: onBack,
                        icon: Icon(Icons.arrow_back, color: textColor),
                        label: Text('BACK', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
                      ),
                      Row(
                        children: [
                          Text(
                            '${widget.game.gameData?.totalTime ?? 0}',
                            style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor,),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.access_time, size: 18, color: textColor),
                        ],
                      ),
                    ],
                  ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 28),
        onPressed: onPressed,
        splashRadius: 24,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}