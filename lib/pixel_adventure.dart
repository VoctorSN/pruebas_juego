import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/buttons_game/custom_joystick.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/main_menu/main_menu.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'components/HUD/buttons_game/changePlayerSkinButton.dart';
import 'components/HUD/buttons_game/jump_button.dart';
import 'components/HUD/buttons_game/open_menu_button.dart';
import 'components/HUD/buttons_game/open_level_selection.dart';
import 'components/HUD/widgets_settings/character_selecition.dart';
import 'components/HUD/widgets_settings/pause_menu.dart';
import 'components/HUD/widgets_settings/settings/settings_menu.dart';
import 'components/game/content/levelBasics/player.dart';
import 'components/game/level/level.dart';

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
    '1',
    '2',
    '3',
    'Mask Dude',
    'Ninja Frog',
    'Pink Man',
    'Virtual Guy',
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
    'level-03',
    'level-04',
    'level-05',
    'level-06',
    'level-07',
    'level-08',
  ];
  int currentLevelIndex = 2;

  // Logic to manage the sounds
  bool isMusicActive = false;
  double musicSoundVolume = 1.0;
  bool isGameSoundsActive = true;
  double gameSoundVolume = 1.0;

  // Logic to manage the HUD, controls, size of the buttons and the positions
  late CustomJoystick customJoystick;
  bool showControls = false;
  double hudSize = 50;
  double controlSize = 50;
  bool isLeftHanded = false;
  late final ChangePlayerSkinButton changeSkinButton;
  late final OpenMenuButton menuButton;
  late final LevelSelection levelSelectionButton;
  late final JumpButton jumpButton;
  bool isJoystickAdded = false;
  late final Vector2 rightControlPosition = Vector2(
    size.x - 32 - controlSize,
    size.y - 32 - controlSize,
  );
  late final Vector2 leftControlPosition = customJoystick.joystick.position;

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
    } catch (e) {
      showControls = false;
    }

    // Initialize the buttons
    changeSkinButton = ChangePlayerSkinButton(
      changeCharacter: openChangeCharacterMenu,
      buttonSize: hudSize,
    );
    menuButton = OpenMenuButton(button: 'menuButton', buttonSize: hudSize);
    levelSelectionButton = LevelSelection(buttonSize: hudSize);
    jumpButton = JumpButton(controlSize,rightControlPosition);

    addAllButtons();

    // Load the overlays for the pause menu and settings menu
    overlays.addEntry(PauseMenu.id, (context, game) => PauseMenu(this));
    overlays.addEntry(SettingsMenu.id, (context, game) => SettingsMenu(this));
    overlays.addEntry(CharacterSelection.id, (context, game) => CharacterSelection(this));
    overlays.addEntry(MainMenu.id, (context, game) => MainMenu(this));

    // Open the main menu
    overlays.add(MainMenu.id);
    pauseEngine();

    // Load the first level
    _loadLevel();

    return super.onLoad();
  }

  void reloadAllButtons() {
    removeControls();
    for (var component in children.where(
      (component) =>
          component is ChangePlayerSkinButton ||
          component is LevelSelection ||
          component is OpenMenuButton,
    )) {
      component.removeFromParent();
    }
    addAllButtons();
  }

  void removeControls() {
      if (children.any((component) => component is JoystickComponent)) {
        isJoystickAdded = false;
        customJoystick.joystick.removeFromParent();
      }
      for (var component in children.whereType<JumpButton>()) {
        component.removeFromParent();
      }
  }

  void addAllButtons() {
    changeSkinButton.size = Vector2.all(hudSize);
    levelSelectionButton.size = Vector2.all(hudSize);
    menuButton.size = Vector2.all(hudSize);
    changeSkinButton.position = Vector2(size.x - (hudSize * 3) - 40, 10);
    levelSelectionButton.position = Vector2(size.x - (hudSize * 2) - 30, 10);
    menuButton.position = Vector2(size.x - hudSize - 20, 10);
    addAll([changeSkinButton, levelSelectionButton, menuButton]);
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

  void addJoystick() {
    if (!isJoystickAdded) {
      isJoystickAdded = true;
      customJoystick = CustomJoystick(
        controlSize: controlSize,
      );
      add(customJoystick);
    }
  }

  void selectedCharacterIndex(int index) {
    currentCharacterIndex = index;
    player.updateCharacter(characters[currentCharacterIndex]);
  }

  void openChangeCharacterMenu() {
    overlays.add(CharacterSelection.id);
    pauseEngine();
  }

  void pauseGame() {
    overlays.add(PauseMenu.id);
    pauseEngine();
  }

  void switchHUDPosition() {
    print("jumpButton.position ${jumpButton.position}");
    if(!showControls) return;
    if(isLeftHanded){
      jumpButton.position = leftControlPosition;
    } else {
      jumpButton.position = rightControlPosition;
    }
    print("isLeftHanded $isLeftHanded");
    print("rightControlPosition $rightControlPosition");
    print("leftControlPosition $leftControlPosition");
    print("jumpButton.position ${jumpButton.position}");
    reloadAllButtons();
  }
}