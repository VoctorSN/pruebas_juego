import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/sound_manager.dart';

import 'components/HUD/buttons_game/changePlayerSkinButton.dart';
import 'components/HUD/buttons_game/jump_button.dart';
import 'components/HUD/buttons_game/open_menu_button.dart';
import 'components/HUD/buttons_game/toggle_sound_button.dart';
import 'components/HUD/widgets_settings/pause_menu.dart';
import 'components/HUD/widgets_settings/settings_menu.dart';
import 'components/game/level.dart';
import 'components/game/spawnpoints/levelContent/player.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {

  // Logic to load the level and the player
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  final List<String> characters = [
    'Mask Dude',
    'Ninja Frog',
    'Pink Man',
    'Virtual Guy',
    '1',
    '2',
    '3',
  ];
  int currentCharacterIndex = 0;
  late Player player;
  late Level level;

  // Logic to manage the levels
  static const List<String> levelNames = [
    'tutorial-01',
    'tutorial-02',
    'tutorial-03',
    'tutorial-04',
    'level-01',
    'level-02',
    // 'level-03', => lvl de viti imposible
    'level-04',
    'level-05',
    'level-06',
    'level-07',
    'level-08',
  ];
  int currentLevelIndex = 10;

  // Logic to manage the sounds
  bool isMusicActive = false;
  double musicSoundVolume = 1.0;
  bool isGameSoundsActive = true;
  double gameSoundVolume = 1.0;

  // Logic to manage the HUD, controls, size of the buttons and the positions
  late JoystickComponent joystick;
  bool showControls = false;
  double hudSize = 50;
  double controlSize = 50;
  bool isLeftHanded = false;
  late final ChangePlayerSkinButton changeSkinButton;
  late final OpenMenuButton menuButton;
  late final JumpButton jumpButton;

  @override
  FutureOr<void> onLoad() async {

    FlameAudio.bgm.initialize();

    // Load all the images and sounds in cache
    await images.loadAllImages();
    await SoundManager().init();

    // Load the player skin
    player = Player(character: characters[currentCharacterIndex]);

    // Detect if the device is a mobile device to show the controls
    try {
      showControls = Platform.isAndroid || Platform.isIOS;
    } catch (e) {}

    // Load the overlays for the pause menu and settings menu
    overlays.addEntry(PauseMenu.id, (context, game) => PauseMenu(this));
    overlays.addEntry(SettingsMenu.id, (context, game) => SettingsMenu(this));

    // Initialize the buttons
    changeSkinButton = ChangePlayerSkinButton(
      changeCharacter: changeCharacter,
      buttonSize: hudSize,
    );
    menuButton = OpenMenuButton(button: 'menuButton', buttonSize: hudSize);
    jumpButton = JumpButton(controlSize);

    addAllButtons();

    // Load the first level
    _loadLevel();

    return super.onLoad();
  }

  void reloadAllButtons() {
    removeControls();
    for (var component in children.where(
      (component) =>
          component is ChangePlayerSkinButton ||
          component is ToggleSoundButton ||
          component is OpenMenuButton,
    )) {
      component.removeFromParent();
    }
    addAllButtons();
  }

  void removeControls() {
      if (children.any((component) => component is JoystickComponent)) {
        joystick.removeFromParent();
      }
      for (var component in children.whereType<JumpButton>()) {
        component.removeFromParent();
      }
  }

  void addAllButtons() {
    changeSkinButton.size = Vector2.all(hudSize);
    menuButton.size = Vector2.all(hudSize);
    changeSkinButton.position = Vector2(size.x - (hudSize * 3) - 40, 10);
    menuButton.position = Vector2(size.x - hudSize - 20, 10);
    addAll([changeSkinButton, menuButton]);
    if (showControls) {
      jumpButton.size = Vector2.all(controlSize * 2);
      add(jumpButton);
      addJoystick();
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //Game Finished - Reload the first level (for the moment)
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    if (isMusicActive) {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play('background_music.mp3');
    }
    level = Level(levelName: levelNames[currentLevelIndex], player: player);

    cam = CameraComponent.withFixedResolution(
      world: level,
      width: 640,
      height: 368,
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
        size: Vector2.all(controlSize),
      ),
      knobRadius: 40,
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('GUI/HUD/Joystick.png')),
        size: Vector2.all(controlSize * 2),
      ),
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
    currentCharacterIndex++;
    if (currentCharacterIndex >= characters.length) {
      currentCharacterIndex = 0;
    }
    level.player.updateCharacter(characters[currentCharacterIndex]);
  }

  void pauseGame() {
    overlays.add(PauseMenu.id);
    pauseEngine();
  }

  void switchHUDPosition() {
    isLeftHanded = !isLeftHanded;
    if (isLeftHanded) {
      jumpButton.position = joystick.position;
    } else {}
    reloadAllButtons();
  }
}