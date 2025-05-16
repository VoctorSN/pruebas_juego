import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/buttons_game/custom_joystick.dart';
import 'package:fruit_collector/components/HUD/widgets/main_menu/main_menu.dart';
import 'package:fruit_collector/components/bbdd/models/game_level.dart';
import 'package:fruit_collector/components/bbdd/services/level_service.dart';
import 'package:fruit_collector/components/game/level/death_screen.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';

import 'components/HUD/buttons_game/achievements_button.dart';
import 'components/HUD/buttons_game/change_player_skin_button.dart';
import 'components/HUD/buttons_game/jump_button.dart';
import 'components/HUD/buttons_game/open_level_selection.dart';
import 'components/HUD/buttons_game/open_menu_button.dart';
import 'components/HUD/widgets/achievement_toast.dart';
import 'components/HUD/widgets/achievements_menu.dart';
import 'components/HUD/widgets/character_selection.dart';
import 'components/HUD/widgets/level_selection_menu.dart';
import 'components/HUD/widgets/main_menu/game_selector.dart';
import 'components/HUD/widgets/pause_menu.dart';
import 'components/HUD/widgets/settings/settings_menu.dart';
import 'components/bbdd/models/achievement.dart';
import 'components/bbdd/models/game.dart' as models;
import 'components/bbdd/services/game_service.dart';
import 'components/game/achievements/achievement_manager.dart';
import 'components/game/achievements/game_stats.dart';
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

  GameService? gameService;
  LevelService? levelService;

  final List<String> characters = [
    '1',
    '2',
    '3',
    'Mask Dude',
    'Ninja Frog',
    'Pink Man',
    'Virtual Guy',
  ];
  late Player player;
  late Level level;

  List<Map<String, dynamic>> levels = [];

  List<int> get unlockedLevelIndices =>
      levels
          .asMap()
          .entries
          .where((entry) => (entry.value['gameLevel'] as GameLevel).unlocked)
          .map((entry) => entry.key)
          .toList();

  List<int> get completedLevelIndices =>
      levels
          .asMap()
          .entries
          .where((entry) => (entry.value['gameLevel'] as GameLevel).completed)
          .map((entry) => entry.key)
          .toList();

  Map<int, int> get starsPerLevel => levels.asMap().map(
    (index, level) => MapEntry(index, ((level['gameLevel'] as GameLevel).stars)),
  );

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
    game: this,
  );
  Achievement? currentAchievement;
  Map<int, int> levelTimes = {};
  Map<int, int> levelDeaths = {};

  models.Game? gameData;

  Future<void> chargeGame(models.Game game) async {
    print('chargeGame');
    gameData = game;

    levelService = await LevelService.getInstance();
    levels = await levelService!.getLevelsForGame(gameData!.id);
    print('levels : $levels');

    ///load first level with data
    _loadActualLevel();
  }

  Future<void> chargeSlot(int slot) async {
    await getGameService();
    gameData = await gameService!.getOrCreateGameBySpace(space: slot);

    levelService = await LevelService.getInstance();
    levels = await levelService!.getLevelsForGame(gameData!.id);
    print('levels : $levels');

    ///load first level with data
    _loadActualLevel();
  }

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();

    // Load all the images and sounds in cache
    await images.loadAllImages();
    await SoundManager().init();

    // Load the player skin
    player = Player(character: characters[gameData?.currentCharacter ?? 0]);

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
      (context, game) =>
          AchievementMenu(this, achievementManager.allAchievements),
    );
    overlays.addEntry(MainMenu.id, (context, game) => MainMenu(this));
    overlays.addEntry(GameSelector.id, (context, game) => GameSelector(this));
    overlays.addEntry(AchievementToast.id, (context, game) {
      final pixelAdventure = game as PixelAdventure;
      return pixelAdventure.currentAchievement == null
          ? const SizedBox.shrink()
          : AchievementToast(
            achievement: pixelAdventure.currentAchievement!,
            onDismiss: () => overlays.remove(AchievementToast.id),
          );
    });
    overlays.addEntry(
      LevelSelectionMenu.id,
      (context, game) => LevelSelectionMenu(
        game: this,
        totalLevels: levels.length,
        onLevelSelected: (level) async {
          final GameService service = await GameService.getInstance();
          await service.saveGameBySpace(game: gameData);

          overlays.remove(LevelSelectionMenu.id);
          resumeEngine();
          gameData?.currentLevel = level - 1;
          _loadActualLevel();
        },
        unlockedLevels: unlockedLevelIndices,
        completedLevels: completedLevelIndices,
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
    achievementsButton.position = Vector2((hudSize * 3) - 10, 10);
    changeSkinButton.position = Vector2((hudSize * 2) - 20, 10);
    levelSelectionButton.position = Vector2(hudSize - 30, 10);
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
      currentLevel: gameData?.currentLevel ?? 0 + 1,
      levelName: level.levelName,
      unlockedLevels: List.from(unlockedLevelIndices),
      completedLevels: List.from(completedLevelIndices),
      starsPerLevel: Map.from(starsPerLevel),
      totalDeaths: gameData?.totalDeaths ?? 0,
      totalTime: gameData?.totalTime ?? 0,
      levelTimes: Map.from(levelTimes),
      levelDeaths: Map.from(levelDeaths),
    );
  }

  void updateGlobalStats() {
    if (gameData == null) return;
    gameData!.totalTime += level.levelTime;
    gameData!.totalDeaths += level.deathCount;
    levelTimes[gameData!.currentLevel] = level.levelTime;
    levelDeaths[gameData!.currentLevel] = level.deathCount;
  }

  void completeLevel() async {
  level.stopLevelTimer();

  updateGlobalStats();

  removeAudios();

  removeWhere((component) => component is Level);

  if (gameData != null) {
    final int currentLevel = gameData!.currentLevel;

    // Mark the current level as completed
    GameLevel currentGameLevel = levels[currentLevel]['gameLevel'] as GameLevel;
    currentGameLevel.completed = true;
    print('Level $currentLevel marked as completed!');

    // Unlock the next level if it exists
    if (currentLevel < levels.length - 1) {
      GameLevel nextGameLevel = levels[currentLevel + 1]['gameLevel'] as GameLevel;
      nextGameLevel.unlocked = true;
      print('Level ${currentLevel + 1} unlocked!');
      gameData!.currentLevel = currentLevel + 1;
      _loadActualLevel();
    } else {
      // If it's the last level, show the end screen
      _showEndScreen();
      gameData!.currentLevel = 0;
      _loadActualLevel();
    }
  }

  await level.saveLevel();

  print(levelDeaths);
  print(starsPerLevel);
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

  void _loadActualLevel() async {
    final service = await GameService.getInstance();
    service.saveGameBySpace(game: gameData);
    removeAudios();
    removeWhere((component) => component is Level);
    if (isMusicActive) {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play('background_music.mp3', volume: musicSoundVolume);
    }
    level = Level(
      levelName: levels[gameData?.currentLevel ?? 0]['level'].name,
      player: player,
    );

    cam = CameraComponent.withFixedResolution(
      world: level,
      width: 640,
      height: 368,
    );

    cam.priority = 10;
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, level]);
    achievementManager.evaluate(getGameStats());
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
    if (gameData == null) return;
    gameData!.currentCharacter = index;
    player.updateCharacter(characters[index]);
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
    final gameDeaths = gameData?.totalDeaths ?? 0;
    deathScreen.addBlackScreen(gameDeaths + level.deathCount);
  }

  Future<void> getGameService() async {
    gameService ??= await GameService.getInstance();
  }
}