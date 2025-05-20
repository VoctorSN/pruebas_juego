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

  const AchievementDetails(this.game, this.achievement, {super.key});

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
    const Color textColor = Color(0xFFE1E0F5);

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
}
