import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../pixel_adventure.dart';
import '../style/text_style_singleton.dart';
import 'level_card.dart';

class LevelSelectionMenu extends StatefulWidget {
  static const String id = 'level_selection_menu';

  final int totalLevels;
  final void Function(int) onLevelSelected;
  final List<int> unlockedLevels;
  final List<int> completedLevels;
  final Map<int, int> starsPerLevel;
  final PixelAdventure game;

  const LevelSelectionMenu({
    super.key,
    required this.game,
    required this.totalLevels,
    required this.onLevelSelected,
    required this.starsPerLevel,
    this.unlockedLevels = const [],
    this.completedLevels = const [],
  });

  @override
  State<LevelSelectionMenu> createState() => _LevelSelectionMenuState();
}

class _LevelSelectionMenuState extends State<LevelSelectionMenu> {
  final ScrollController _scrollController = ScrollController();

  static const double _cardHeight = 100;
  static const double _cardSpacing = 12;
  static const double _minCardWidth = 80;
  static const double _minCardsPerRow = 3;

  void scrollByRow({required bool forward}) {
    // Calculate the total height of one row (card height + spacing)
    const double rowHeight = _cardHeight + _cardSpacing;

    // Determine the current row based on the scroll offset
    final double currentOffset = _scrollController.offset;
    final int currentRow = (currentOffset / rowHeight).round();

    // Calculate the target row (next or previous)
    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, double.infinity).toInt();

    // Calculate the target offset for the top of the target row
    final double targetOffset = targetRow * rowHeight;

    // Animate to the target offset
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
              final double calculatedCardsPerRow = (availableWidth / (_minCardWidth + _cardSpacing)).floorToDouble();
              final double cardsPerRow = calculatedCardsPerRow.clamp(_minCardsPerRow, double.infinity);
              final double cardWidth = (availableWidth - (_cardSpacing * (cardsPerRow - 1))) / cardsPerRow;

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
                                  final int level = index + 1;
                                  final bool isUnlocked = widget.unlockedLevels.contains(level);
                                  final bool isCompleted = widget.completedLevels.contains(level);

                                  return SizedBox(
                                    height: _cardHeight,
                                    width: cardWidth,
                                    child: LevelCard(
                                      levelNumber: level,
                                      onTap: isUnlocked ? () => widget.onLevelSelected(level) : null,
                                      cardColor: cardColor,
                                      borderColor: borderColor,
                                      stars: widget.starsPerLevel[level] ?? 0,
                                      textColor: textColor,
                                      isLocked: !isUnlocked,
                                      isCompleted: isCompleted,
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
                                onPressed: () => scrollByRow(forward: false),
                                color: cardColor,
                                iconColor: textColor,
                                borderColor: borderColor,
                              ),
                              const SizedBox(height: 8),
                              _buildScrollButton(
                                icon: Icons.keyboard_arrow_down,
                                onPressed: () => scrollByRow(forward: true),
                                color: cardColor,
                                iconColor: textColor,
                                borderColor: borderColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: buttonStyle,
                      onPressed: onBack,
                      icon: Icon(Icons.arrow_back, color: textColor),
                      label: Text(
                        'BACK',
                        style: TextStyleSingleton().style.copyWith(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
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