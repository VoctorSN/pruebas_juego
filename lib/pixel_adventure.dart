import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/components/changePlayerSkinButton.dart';
import 'package:flutter_flame/components/jump_button.dart';
import 'package:flutter_flame/components/level.dart';
import 'package:flutter_flame/components/player.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection, TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  final List<String> characters = ['Mask Dude', 'Ninja Frog', 'Pink Man', 'Virtual Guy'];
  int currentCharacterIndex = 0;
  late Player player;
  late Level level;
  late JoystickComponent joystick;
  bool showControls = false;
  static const List<String> levelNames = ['Level-01', 'Level-02', 'Level-03',];
  int currentLevelIndex = 0;
  bool playSounds = true;
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {
    // Carga todas las imagenes al caché
    await images.loadAllImages();
    player = Player(character: characters[currentCharacterIndex]);

    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
    }
    add(ChangePlayerSkinButton(buttonImage: 'LeftArrow', toRight: true, marginVertical: 550, marginHorizontal: 200, changeCharacter: changeCharacter));
    add(ChangePlayerSkinButton(buttonImage: 'RightArrow', toRight: true, marginVertical: 550, marginHorizontal: 50, changeCharacter: changeCharacter));
    return super.onLoad();
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //Game Finished
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      level = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );

      cam = CameraComponent.withFixedResolution(
        world: level,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, level]);
    });
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
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
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.right:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void changeCharacter() {
    print('cambiando personaje: ${level.player.character}');
    currentCharacterIndex++;
    if(currentCharacterIndex >= characters.length){
      currentCharacterIndex = 0;
    }
    level.player.updateCharacter(characters[currentCharacterIndex]);
  }
}