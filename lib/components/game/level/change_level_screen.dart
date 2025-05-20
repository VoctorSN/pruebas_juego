import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../pixel_adventure.dart';

class LevelCompleteScreen extends Component {
  final Function gameAdd;
  final Function gameRemove;
  final PixelAdventure game;

  final Vector2 screenSize;
  final String levelName;
  final int difficulty;
  final int deaths;
  final int stars;
  final double time;

  final List<RectangleComponent> closingRects = [];
  late RectangleComponent blackOverlay;
  final List<Component> infoComponents = [];

  LevelCompleteScreen({
    required this.gameAdd,
    required this.gameRemove,
    required this.game,
    required this.screenSize,
    required this.levelName,
    required this.difficulty,
    required this.deaths,
    required this.stars,
    required this.time,
  });

  Future<void> show() async {
    _createCornerRects();

    for (final rect in closingRects) {
      gameAdd(rect);
    }

    // Animate rectangles to cover screen from corners
    final duration = 600;
    final steps = (duration / 16).ceil();

    for (int step = 0; step <= steps; step++) {
      final t = step / steps;
      final scale = (screenSize.x / 2) * t;

      // Update each rect size and position
      for (int i = 0; i < closingRects.length; i++) {
        final rect = closingRects[i];

        switch (i) {
          case 0: // top-left
            rect.size = Vector2(scale, scale);
            break;
          case 1: // top-right
            rect.size = Vector2(scale, scale);
            rect.position = Vector2(screenSize.x - scale, 0);
            break;
          case 2: // bottom-left
            rect.size = Vector2(scale, scale);
            rect.position = Vector2(0, screenSize.y - scale);
            break;
          case 3: // bottom-right
            rect.size = Vector2(scale, scale);
            rect.position = screenSize - Vector2.all(scale);
            break;
        }
      }

      await Future.delayed(const Duration(milliseconds: 16));
    }

    // Remove corners and replace with full black screen
    for (final rect in closingRects) {
      gameRemove(rect);
    }
    closingRects.clear();

    blackOverlay = RectangleComponent(
      size: screenSize,
      paint: Paint()..color = Colors.black,
      priority: 1000,
    );
    gameAdd(blackOverlay);

    await _showLevelInfo();
    gameRemove(blackOverlay);
    for (final c in infoComponents) {
      c.removeFromParent();
    }
  }

  void _createCornerRects() {
    for (int i = 0; i < 4; i++) {
      final rect = RectangleComponent(
        size: Vector2.zero(),
        position: Vector2.zero(),
        paint: Paint()..color = Colors.black,
        priority: 999,
      );
      closingRects.add(rect);
    }
  }

  Future<void> _showLevelInfo() async {
    final textStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'ArcadeClassic',
      color: Colors.white,
    );

    final difficultyStars = '★' * difficulty;
    final deathsText = deaths > 0 ? '$deaths deaths' : '??? deaths';
    final starsText = stars > 0 ? '$stars stars' : '??? stars';
    final timeText = time > 0 ? '${time.toStringAsFixed(2)} sec' : '??? time';

    final List<String> lines = [
      levelName,
      difficultyStars,
      deathsText,
      starsText,
      timeText,
    ];

    final spacing = 40.0;
    final startY = screenSize.y / 2 - (lines.length - 1) * spacing / 2;

    for (int i = 0; i < lines.length; i++) {
      final text = TextComponent(
        text: lines[i],
        textRenderer: TextPaint(style: textStyle),
        anchor: Anchor.center,
        position: Vector2(screenSize.x / 2, startY + i * spacing),
        priority: 1001,
      );
      infoComponents.add(text);
      blackOverlay.add(text);
    }

    await Future.delayed(const Duration(seconds: 2));
  }
}

// final screen = LevelCompleteScreen(
//   gameAdd: game.add,
//   gameRemove: game.remove,
//   game: game,
//   screenSize: game.size,
//   levelName: 'Jungle Madness',
//   difficulty: 3,
//   deaths: 2,
//   stars: 4,
//   time: 123.45,
// );
// await screen.show();