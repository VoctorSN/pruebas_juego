import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/components/bbdd/models/achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/pixel_adventure.dart';

/// TODO: change stars to other icons and load achievements

class AchievementMenu extends StatefulWidget {
  final PixelAdventure game;
  final List<Map<String, dynamic>> achievements;

  const AchievementMenu(this.game, this.achievements, {super.key});

  static const String id = 'achievement_menu';

  @override
  State<AchievementMenu> createState() => _AchievementMenuState();
}

class _AchievementMenuState extends State<AchievementMenu> {
  final ScrollController _scrollController = ScrollController();

  static const double _rowHeight = 100;
  static const double _rowSpacing = 12;

  void _scrollByRow({required bool forward}) {
    final double currentOffset = _scrollController.offset;
    final int currentRow = (currentOffset / (_rowHeight + _rowSpacing)).round();
    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, widget.achievements.length - 1);
    final double targetOffset = targetRow * (_rowHeight + _rowSpacing);

    _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _onBack() {
    widget.game.overlays.remove(AchievementMenu.id);
    widget.game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    const Color baseColor = Color(0xFF212030);
    const Color cardColor = Color(0xFF3A3750);
    const Color borderColor = Color(0xFF5A5672);
    const Color textColor = Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: cardColor,
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderColor, width: 2),
      ),
      elevation: 6,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: 600,
              height: 500,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'ACHIEVEMENTS',
                    style: TextStyleSingleton().style.copyWith(
                      fontSize: 28,
                      color: textColor,
                      shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            itemCount: widget.achievements.length,
                            separatorBuilder: (_, __) => const SizedBox(height: _rowSpacing),
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> achievementData = widget.achievements[index];
                              final Achievement achievement = achievementData['achievement'];
                              final GameAchievement gameAchievement = achievementData['gameAchievement'];
                              final String trophyPath =
                                  gameAchievement.achieved
                                      ? 'assets/images/GUI/HUD/trophy_gold.png'
                                      : 'assets/images/GUI/HUD/trophy_gray.png';

                              return Container(
                                height: _rowHeight,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  border: Border.all(color: borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(trophyPath, width: 36, height: 36, fit: BoxFit.contain),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            achievement.description,
                                            style: const TextStyle(fontSize: 14, color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                Icons.star,
                                                size: 16,
                                                color: i < achievement.difficulty ? Colors.amber : Colors.grey,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildScrollButton(
                              icon: Icons.keyboard_arrow_up,
                              onPressed: () => _scrollByRow(forward: false),
                              color: cardColor,
                              iconColor: textColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 12),
                            _buildScrollButton(
                              icon: Icons.keyboard_arrow_down,
                              onPressed: () => _scrollByRow(forward: true),
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
                        onPressed: _onBack,
                        icon: const Icon(Icons.arrow_back, color: textColor),
                        label: Text('BACK', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
                      ),
                      Row(
                        children: [
                          Text(
                            '${widget.game.gameData?.totalTime ?? 0}',
                            style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor,),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.access_time, size: 18, color: textColor),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        icon: Icon(icon, color: iconColor, size: 24),
        onPressed: onPressed,
        splashRadius: 20,
        padding: const EdgeInsets.all(10),
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