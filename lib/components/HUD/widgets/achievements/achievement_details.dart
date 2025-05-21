import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/components/bbdd/models/achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/pixel_adventure.dart';

class AchievementDetails extends StatefulWidget {
  final PixelAdventure game;
  final Achievement achievement;
  final GameAchievement gameAchievement;

  const AchievementDetails(this.game, this.achievement, this.gameAchievement, {super.key});

  static const String id = 'achievement_details';

  @override
  State<AchievementDetails> createState() => _AchievementDetailsState();
}

class _AchievementDetailsState extends State<AchievementDetails> {
  Achievement? selectedAchievement;

  @override
  Widget build(BuildContext context) {
    const Color baseColor = Color(0xFF212030);
    const Color borderColor = Color(0xFF5A5672);
    final Color buttonColor = const Color(0xFF3A3750);
    const Color textColor = Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: Size(MediaQuery.of(context).size.width * 0.1, MediaQuery.of(context).size.height * 0.0625),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderColor, width: 2),
      ),
      elevation: 8,
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
                  height: MediaQuery.of(context).size.height * 0.5,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.achievement.title,
                        style: TextStyleSingleton().style.copyWith(
                          fontSize: 28,
                          color: textColor,
                          shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              widget.achievement.description,
                              textAlign: TextAlign.center,
                              style: TextStyleSingleton().style.copyWith(
                                fontSize: 18,
                                color: textColor,
                                shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Image.asset(
                                'assets/images/difficulty/difficulty${widget.achievement.difficulty.clamp(1, 10)}-Photoroom.png',
                                width: MediaQuery.of(context).size.width * 0.0625,
                                height: MediaQuery.of(context).size.width * 0.0625,
                                fit: BoxFit.contain,
                              ),

                          ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Image.asset(
                                widget.gameAchievement.achieved
                                    ? 'assets/images/Trophys/Achieved.png'
                                    : 'assets/images/Trophys/Not Achieved.png',
                                width: MediaQuery.of(context).size.width * 0.0625,
                                height: MediaQuery.of(context).size.width * 0.0625,
                                fit: BoxFit.contain,

                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: buttonStyle,
                        onPressed: _onBack,
                        icon: const Icon(Icons.arrow_back, color: textColor),
                        label: Text('BACK', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
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
  }

  void _onBack() {
    widget.game.overlays.remove(AchievementDetails.id);
  }
}
