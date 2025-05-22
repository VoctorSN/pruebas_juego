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
  @override
  Widget build(BuildContext context) {
    const Color baseColor = Color(0xFF212030);
    const Color cardColor = Color(0xFF3A3750);
    const Color borderColor = Color(0xFF5A5672);
    const Color textColor = Color(0xFFE1E0F5);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double maxWidth = (constraints.maxWidth * 0.6).clamp(320.0, 600.0);
              final double maxHeight = (constraints.maxHeight * 0.6).clamp(300.0, 500.0);
              final double imageSize = maxWidth * 0.15;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.achievement.title,
                      textAlign: TextAlign.center,
                      style: TextStyleSingleton().style.copyWith(
                        fontSize: 24,
                        color: textColor,
                        shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.achievement.description,
                            textAlign: TextAlign.center,
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 16,
                              color: textColor,
                              height: 1.4,
                              shadows: const [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/difficulty/difficulty${widget.achievement.difficulty.clamp(1, 10)}-Photoroom.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.contain,
                        ),
                        ElevatedButton.icon(
                          style: buttonStyle,
                          onPressed: _onBack,
                          icon: const Icon(Icons.arrow_back, color: textColor),
                          label: Text(
                            'BACK',
                            style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                          ),
                        ),
                        Image.asset(
                          widget.gameAchievement.achieved
                              ? 'assets/images/Trophys/Achieved.png'
                              : 'assets/images/Trophys/Not Achieved.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.contain,
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

  void _onBack() {
    widget.game.overlays.remove(AchievementDetails.id);
  }
}
