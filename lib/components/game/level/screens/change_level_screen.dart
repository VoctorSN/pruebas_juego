import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../pixel_adventure.dart';

class LevelCompleteScreen extends Component {
  // Constructor and attributes
  final Function gameAdd;
  final Function gameRemove;
  final PixelAdventure game;

  LevelCompleteScreen({
    required this.gameAdd,
    required this.gameRemove,
    required this.game,
  });

  // Info of the level
  late final Vector2 screenSize = game.size;
  late final String levelName = game.level.levelName;
  late final int difficulty =
      game.levels[game.gameData!.currentLevel]['level'].difficulty;
  late final int deaths = game.level.minorDeaths;
  late final int stars = game.level.starsCollected;
  late final int time = game.level.minorLevelTime;

  final List<RectangleComponent> closingRects = [];
  late RectangleComponent blackOverlay;
  final List<Component> infoComponents = [];

  Future<void> show() async {
    final center = screenSize / 2;

    final expandingCircle = ExpandableCircleComponent(
      center: center,
      maxRadius: screenSize.length,
    )..priority = 999;

    gameAdd(expandingCircle);

    const duration = 600;
    final steps = (duration / 16).ceil();

    double easeOutQuad(double t) => t * (2 - t);

    for (int step = 0; step <= steps; step++) {
      final double t = step / steps;
      final double eased = easeOutQuad(t);
      final double radius = screenSize.length * eased;

      expandingCircle._radius = radius;

      await Future.delayed(const Duration(milliseconds: 16));
    }

    gameRemove(expandingCircle);

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

    await Future.delayed(const Duration(seconds: 2), () {
      for (final c in infoComponents) {
        if (c is ExpandableCircleComponent) {
          c.startCollapse(
            onComplete: () {
              c.removeFromParent();
            },
          );
        }
      }
    });
  }
}

enum CircleAnimationState { idle, expanding, collapsing }

class ExpandableCircleComponent extends PositionComponent {
  final Vector2 center;
  final double maxRadius;
  final double durationMs;
  final Paint circlePaint;

  double _radius = 0.0;
  double _elapsed = 0.0;
  CircleAnimationState _state = CircleAnimationState.idle;
  VoidCallback? onCollapseEnd;

  ExpandableCircleComponent({
    required this.center,
    required this.maxRadius,
    this.durationMs = 600,
    Color color = Colors.black,
  }) : circlePaint = Paint()..color = color,
       super(priority: 2000);

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(center.x, center.y), _radius, circlePaint);
  }

  @override
  void update(double dt) {
    if (_state == CircleAnimationState.idle) return;

    _elapsed += dt * 1000; // Convertir a milisegundos
    final progress = (_elapsed / durationMs).clamp(0.0, 1.0);
    final eased = progress * (2 - progress); // easeOutQuad

    if (_state == CircleAnimationState.expanding) {
      _radius = maxRadius * eased;
      if (progress >= 1.0) {
        _state = CircleAnimationState.idle;
      }
    } else if (_state == CircleAnimationState.collapsing) {
      _radius = maxRadius * (1 - eased);
      if (progress >= 1.0) {
        _state = CircleAnimationState.idle;
        removeFromParent();
        if (onCollapseEnd != null) {
          onCollapseEnd!();
        }
      }
    }
  }

  void startExpand() {
    _state = CircleAnimationState.expanding;
    _elapsed = 0.0;
    _radius = 0.0;
  }

  void startCollapse({VoidCallback? onComplete}) {
    _state = CircleAnimationState.collapsing;
    _elapsed = 0.0;
    _radius = maxRadius;
    onCollapseEnd = onComplete;
  }

  @override
  bool get isHud => true;
}
