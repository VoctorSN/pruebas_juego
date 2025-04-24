import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class GameText extends TextComponent with HasGameReference {
  GameText({
    required String text,
    required Vector2 position,
    double fontSize = 16,
    Color color = Colors.white,
    String fontFamily = 'ArcadeClassic',
  }) : super(
    priority: -3,
    text: text,
    position: position,
    textRenderer: TextPaint(
      style: TextStyle(
        fontFamily: 'ArcadeClassic',
        fontSize: fontSize,
        color: color,
      ),
    ),
  );

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center; // Centra el texto en su posición
  }
}