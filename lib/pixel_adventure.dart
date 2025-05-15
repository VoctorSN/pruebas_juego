import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/buttons_game/custom_joystick.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/main_menu/main_menu.dart';
import 'package:fruit_collector/components/game/level/death_screen.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';

import 'components/HUD/buttons_game/achievements_button.dart';
import 'components/HUD/buttons_game/change_player_skin_button.dart';
import 'components/HUD/buttons_game/jump_button.dart';
import 'components/HUD/buttons_game/open_level_selection.dart';
import 'components/HUD/buttons_game/open_menu_button.dart';
import 'components/HUD/widgets_settings/achievement_toast.dart';
import 'components/HUD/widgets_settings/achievements_menu.dart';
import 'components/HUD/widgets_settings/character_selection.dart';
import 'components/HUD/widgets_settings/level_selection_menu.dart';
import 'components/HUD/widgets_settings/main_menu/game_selector.dart';
import 'components/HUD/widgets_settings/pause_menu.dart';
import 'components/HUD/widgets_settings/settings/settings_menu.dart';
import 'components/bbdd/achievement.dart';
import 'components/bbdd/achievement_manager.dart';
import 'components/bbdd/game_stats.dart';
import 'components/bbdd/info.dart';
import 'components/game/content/levelBasics/player.dart';
import 'components/game/content/traps/fire_block.dart';
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
  late final int _slot;

  int get slot => _slot;

  set slot(int value){
    _slot = value;
  }

  late final int _gameId;

  int get gameId => _gameId;

  set gameId(int value) {
    _gameId = value;
  }

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
    'tutorial-05',
    'level-01',
    'level-02',
    'level-03',
    'level-04',
    'level-05',
    'level-06',
    'level-07',
    'level-08',
    'level-99',
  ];
  int currentLevelIndex = 0;
  List<int> unlockedLevels = [1, 2, 3, 4, 5]; //tutorial levels
  List<int> completedLevels = [];
  Map<int, int> starsPerLevel = {};

  // Logic to manage the sounds
  bool isMusicActive = false;
  double musicSoundVolume = 1.0;
  bool isGameSoundsActive = true;
  double gameSoundVolume = 1.0;

  late DeathScreen deathScreen = DeathScreen(
    gameAdd: (component) {
      add(component);
    },
    gameRemove: (component) {
      remove(component);
    },
    size: size,
    position: Vector2(0, 0),
  )..priority = 1000;

  // Logic to manage the HUD, controls, size of the buttons and the positions
  late CustomJoystick customJoystick;
  bool showControls = false;
  double hudSize = 50;
  double controlSize = 50;
  bool isLeftHanded = false;
  late final ChangePlayerSkinButton changeSkinButton;
  late final OpenMenuButton menuButton;
  late final LevelSelection levelSelectionButton;
  late final AchievementsButton achievementsButton;
  late final JumpButton jumpButton;
  bool isJoystickAdded = false;
  late final Vector2 rightControlPosition = Vector2(
    size.x - 32 - controlSize,
    size.y - 32 - controlSize,
  );
  late final Vector2 leftControlPosition = Vector2(
    32 - controlSize,
    32 - controlSize,
  );

  // Logic to manage achievements
  late final AchievementManager achievementManager = AchievementManager(
    achievements,
    game: this,
  );
  Achievement? currentAchievement;
  int totalDeaths = 0;
  int totalTime = 0;
  Map<int, int> levelTimes = {};
  Map<int, int> levelDeaths = {};

  Future<void> chargeSlot(int slot) async{
    // final game = await GameDatabaseService.instance.getOrCreateGameBySpace(slot);
    // slot = int.parse(game!['space']);
    // gameId = int.parse(game['id']);
    // totalDeaths = int.parse(game['total_deaths']);
    // totalTime = int.parse(game['total_time']);
    // currentLevelIndex = int.parse(game['current_level']) - 1;
  }

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

    initializateButtons();

    addAllButtons();

    addOverlays();

    // Open the main menu
    pauseEngine();
    overlays.add(MainMenu.id);

    // Load the first level
    _loadActualLevel();

    return super.onLoad();
  }

  @override
  void onDispose() {
    super.onDispose();
  }

  void initializateButtons() {
    changeSkinButton = ChangePlayerSkinButton(
      changeCharacter: openChangeCharacterMenu,
      buttonSize: hudSize,
    );
    menuButton = OpenMenuButton(buttonSize: hudSize);
    levelSelectionButton = LevelSelection(
      buttonSize: hudSize,
      onTap: openLevelSelectionMenu,
    );
    achievementsButton = AchievementsButton(buttonSize: hudSize);
    jumpButton = JumpButton(controlSize);
  }

  void addOverlays() {
    overlays.addEntry(PauseMenu.id, (context, game) => PauseMenu(this));
    overlays.addEntry(SettingsMenu.id, (context, game) => SettingsMenu(this));
    overlays.addEntry(
      CharacterSelection.id,
      (context, game) => CharacterSelection(this),
    );
    overlays.addEntry(
      AchievementMenu.id,
      (context, game) => AchievementMenu(this),
    );
    overlays.addEntry(MainMenu.id, (context, game) => MainMenu(this));
    overlays.addEntry(GameSelector.id, (context, game) => GameSelector(this));
    overlays.addEntry(AchievementToast.id, (context, game) {
      final pixelAdventure = game as PixelAdventure;
      return pixelAdventure.currentAchievement == null
          ? const SizedBox.shrink()
          : AchievementToast(achievement: pixelAdventure.currentAchievement!);
    });
    overlays.addEntry(
      LevelSelectionMenu.id,
      (context, game) => LevelSelectionMenu(
        game: this,
        totalLevels: levelNames.length,
        onLevelSelected: (level) {
          overlays.remove(LevelSelectionMenu.id);
          resumeEngine();
          currentLevelIndex = level - 1;
          _loadActualLevel();
        },
        unlockedLevels: unlockedLevels,
        completedLevels: completedLevels,
        starsPerLevel: starsPerLevel,
      ),
    );
  }

  void reloadAllButtons() {
    removeControls();
    for (var component in children.where(
      (component) =>
          component is ChangePlayerSkinButton ||
          component is LevelSelection ||
          component is AchievementsButton ||
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
    achievementsButton.size = Vector2.all(hudSize);
    levelSelectionButton.size = Vector2.all(hudSize);
    menuButton.size = Vector2.all(hudSize);
    achievementsButton.position = Vector2(size.x - (hudSize * 4) - 50, 10);
    changeSkinButton.position = Vector2(size.x - (hudSize * 3) - 40, 10);
    levelSelectionButton.position = Vector2(size.x - (hudSize * 2) - 30, 10);
    menuButton.position = Vector2(size.x - hudSize - 20, 10);
    addAll([
      changeSkinButton,
      levelSelectionButton,
      menuButton,
      achievementsButton,
    ]);
    if (showControls) {
      jumpButton.size = Vector2.all(controlSize * 2);
      add(jumpButton);
      addJoystick();
    }
  }

  GameStats getGameStats() {
    return GameStats(
      currentLevel: currentLevelIndex + 1,
      levelName: level.levelName,
      unlockedLevels: List.from(unlockedLevels),
      completedLevels: List.from(completedLevels),
      starsPerLevel: Map.from(starsPerLevel),
      totalDeaths: totalDeaths,
      totalTime: totalTime,
      levelTimes: Map.from(levelTimes),
      levelDeaths: Map.from(levelDeaths),
    );
  }

  void updateGlobalStats() {
    totalTime += level.levelTime;
    totalDeaths += level.deathCount;
    levelTimes[currentLevelIndex + 1] = level.levelTime;
    levelDeaths[currentLevelIndex + 1] = level.deathCount;
  }

  void completeLevel() {
    final levelNumber = currentLevelIndex + 1;

    level.stopLevelTimer();
    Info(this).getLevel(level);

    updateGlobalStats();

    removeAudios();

    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadActualLevel();
      if (!completedLevels.contains(levelNumber)) {
        completedLevels.add(levelNumber);
      }
      if (!unlockedLevels.contains(levelNumber + 1)) {
        unlockedLevels.add(levelNumber + 1);
      }
    } else {
      _showEndScreen(); // Implemented method to show the end screen
      currentLevelIndex = 0;
      _loadActualLevel();
    }

    achievementManager.evaluate(getGameStats());
  }

  void _showEndScreen() {}

  void removeAudios() {
    try {
      for (final component in level.children) {
        if (component is FireBlock) {
          component.removeSound();
        }
      }
    } catch (e) {
      /// When the leves isn't initialized we dont remove sound
    }
  }

  void _loadActualLevel() {
    removeAudios();
    removeWhere((component) => component is Level);
    if (isMusicActive) {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play('background_music.mp3', volume: musicSoundVolume);
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
        leftMargin: isLeftHanded ? size.x - 32 - controlSize * 2 : 32,
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

  void openLevelSelectionMenu() {
    overlays.add(LevelSelectionMenu.id);
    pauseEngine();
  }

  void pauseGame() {
    overlays.add(PauseMenu.id);
    pauseEngine();
  }

  void switchHUDPosition() {
    if (!showControls) return;
    reloadAllButtons();
  }

  removeBlackScreen() {
    deathScreen.removeBlackScreen();
  }

  addBlackScreen() {
    deathScreen.addBlackScreen(totalDeaths + level.deathCount);
  }
}