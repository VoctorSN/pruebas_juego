import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/components/HUD/buttons/open_menu_button.dart';
import 'package:flutter_flame/components/HUD/widgets/pause_menu.dart';
import 'package:flutter_flame/components/game/level.dart';
import 'components/HUD/buttons/changePlayerSkinButton.dart';
import 'components/HUD/buttons/jump_button.dart';
import 'components/HUD/buttons/toggle_sound_button.dart';
import 'components/HUD/widgets/settings_menu.dart';
import 'components/game/spawnpoints/levelContent/player.dart';

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
  static const List<String> levelNames = ['level-01', 'level-02', 'level-03', 'level-04', 'level-05', 'level-06', 'level-07'];
  int currentLevelIndex = 5;
  bool playSounds = true;
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {

    showControls = Platform.isIOS || Platform.isAndroid;

    // Carga todas las imagenes al caché
    await images.loadAllImages();
    player = Player(character: characters[currentCharacterIndex]);

    overlays.addEntry(
      PauseMenu.id, (context, game) => PauseMenu(this),
    );

    overlays.addEntry(
      SettingsMenu.id, (context, game)=> SettingsMenu(this),
    );

    _loadLevel();

    if (showControls) {
      if (!children.any((component) => component is JoystickComponent)) {
        addJoystick();
      }
      if (!children.any((component) => component is JumpButton)) {
        add(JumpButton());
      }
    }

    add(ChangePlayerSkinButton(changeCharacter: changeCharacter));
    add(ToggleSoundButton(buttonImageOn: 'soundOnButton', buttonImageOff: 'soundOffButton'));
    add(OpenMenuButton(button: 'menuButton'));
    return super.onLoad();
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //Game Finished
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    level = Level(
      levelName: levelNames[currentLevelIndex],
      player: player,
    );

    cam = CameraComponent.withFixedResolution(
      world: level,
      width: 640,
      height: 360,
    );
    cam.priority = 10;
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, level]);
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
        priority: 15,
        knob: SpriteComponent(
          sprite: Sprite(images.fromCache('GUI/HUD/Knob.png')),
          size: Vector2.all(50),
        ),
        knobRadius: 40,
        background: SpriteComponent(
          sprite: Sprite(images.fromCache('GUI/HUD/Joystick.png')),
          size: Vector2.all(100),
        ),
        margin: const EdgeInsets.only(left: 32, bottom: 32)
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
    currentCharacterIndex++;
    if(currentCharacterIndex >= characters.length){
      currentCharacterIndex = 0;
    }
    level.player.updateCharacter(characters[currentCharacterIndex]);
  }

  void pauseGame() {
    overlays.add(PauseMenu.id);
    pauseEngine();
  }
}