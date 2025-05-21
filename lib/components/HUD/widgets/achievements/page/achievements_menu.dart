import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/components/HUD/widgets/achievements/page/achievement_details.dart';
import 'package:fruit_collector/components/bbdd/models/achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import 'package:fruit_collector/components/HUD/widgets/achievements/vm/achievement_menu_vm.dart';

import '../../base_widget.dart';

class AchievementMenu extends StatelessWidget {
  final PixelAdventure game;
  final List<Map<String, dynamic>> achievements;

  const AchievementMenu(this.game, this.achievements, {super.key});

  static const String id = 'achievement_menu';

  @override
  Widget build(BuildContext context) {
    return BaseWidget<AchievementMenuVM>(
      model: AchievementMenuVM(achievements: achievements),
      builder: (context, model, _) {
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

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.6,
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
                              shadows: const [
                                Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    controller: model.scrollController,
                                    itemCount: achievements.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: AchievementMenuVM.rowSpacing),
                                    itemBuilder: (context, index) {
                                      final achievementData = achievements[index];
                                      final Achievement achievement = achievementData['achievement'];
                                      final GameAchievement gameAchievement = achievementData['gameAchievement'];
                                      final String trophyPath = gameAchievement.achieved
                                          ? 'assets/images/GUI/HUD/trophy_gold.png'
                                          : 'assets/images/GUI/HUD/trophy_gray.png';

                                      return GestureDetector(
                                        onTap: () {
                                          game.currentAchievement = achievement;
                                          game.currentGameAchievement = gameAchievement;
                                          game.overlays.add(AchievementDetails.id);
                                        },
                                        child: Container(
                                          height: 70,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            border: Border.all(color: borderColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(trophyPath, width: 24, height: 24, fit: BoxFit.contain),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  achievement.title,
                                                  style: const TextStyle(fontSize: 13, color: textColor),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                                child: Image.asset(
                                                  'assets/images/difficulty/difficulty${achievement.difficulty.clamp(1, 10)}-Photoroom.png',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ),
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
                                      onPressed: () => model.scrollByRow(forward: false),
                                      color: cardColor,
                                      iconColor: textColor,
                                      borderColor: borderColor,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildScrollButton(
                                      icon: Icons.keyboard_arrow_down,
                                      onPressed: () => model.scrollByRow(forward: true),
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
                                    '${game.gameData?.totalDeaths ?? 0}',
                                    style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: buttonStyle,
                                onPressed: () {
                                  game.overlays.remove(AchievementMenu.id);
                                  game.resumeEngine();
                                },
                                icon: const Icon(Icons.arrow_back, color: textColor),
                                label: Text(
                                  'BACK',
                                  style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${game.gameData?.totalTime ?? 0}',
                                    style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
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
            ),
          ],
        );
      },
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
}
