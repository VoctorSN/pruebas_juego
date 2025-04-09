import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter_flame/components/player.dart';
import 'dart:async';

import 'package:flutter_flame/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = false;
  List<String> levelNames = ['Level-01', 'Level-02'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // Carga todas las imagenes al caché
    await images.loadAllImages();

    _loadLevel();

    if (showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //Game Finished
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      final world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    });
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      knobRadius: 36,
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upLeft:
        player.hasJumped = true;
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
        player.hasJumped = true;
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.right:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.up:
        player.hasJumped = true;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}