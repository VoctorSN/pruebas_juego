import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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

  // Lógica para cargar el nivel y el personaje
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  final List<String> characters = [
    'Mask Dude',
    'Ninja Frog',
    'Pink Man',
    'Virtual Guy',
  ];
  int currentCharacterIndex = 0;
  late Player player;
  late Level level;

  // Lógica para gestionar el nivel actual - se ha borrado el lvl 3 pq da error
  static const List<String> levelNames = [
    'level-01',
    'level-02',
    'level-04',
    'level-05',
    'level-06',
    'level-07',
    'level-08',
  ];
  int currentLevelIndex = 6;

  // Lógica para gestionar el volumen
  bool playSounds = true;
  double soundVolume = 1.0;

  // Lógica para gestionar los botones, sus tamaños y el modo zurdo
  late JoystickComponent joystick;
  bool showControls = false;
  double hudSize = 50;
  bool isLeftHanded = false;
  late final ChangePlayerSkinButton changeSkinButton;
  late final ToggleSoundButton soundButton;
  late final OpenMenuButton menuButton;
  late final JumpButton jumpButton;

  @override
  FutureOr<void> onLoad() async {
    // Carga todas las imagenes al caché
    await images.loadAllImages();
    player = Player(character: characters[currentCharacterIndex]);

    // Detectar el SO y cargar los controles, se añade el if porque al cerrar y abrir la aplicación desaparecía el botón de salto
    showControls = Platform.isAndroid || Platform.isIOS;

    // Cargar los overlays para gestionar los menús y el HUD
    overlays.addEntry(PauseMenu.id, (context, game) => PauseMenu(this));
    overlays.addEntry(SettingsMenu.id, (context, game) => SettingsMenu(this));

    // Inicializar los botones sin necesidad de reasignar buttonSize después
    changeSkinButton = ChangePlayerSkinButton(
      changeCharacter: changeCharacter,
      buttonSize: hudSize,
    );
    soundButton = ToggleSoundButton(
      buttonImageOn: 'soundOnButton',
      buttonImageOff: 'soundOffButton',
      buttonSize: hudSize,
    );
    menuButton = OpenMenuButton(
      button: 'menuButton',
      buttonSize: hudSize,
    );
    jumpButton = JumpButton(hudSize);

    addAllButtons();

    // Cargar el nivel inicial
    _loadLevel();

    return super.onLoad();
  }

  void reloadAllButtons() {
    if (showControls) {
      if (children.any((component) => component is JoystickComponent)) {
        joystick.removeFromParent();
      }
      for (var component in children.whereType<JumpButton>()) {
        component.removeFromParent();
      }
    }
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

  void addAllButtons() {
    // TODO Actualizar las posiciones de los botones
    changeSkinButton.size = Vector2.all(hudSize);
    soundButton.size = Vector2.all(hudSize);
    menuButton.size = Vector2.all(hudSize);
    addAll([
      changeSkinButton,
      soundButton,
      menuButton,
    ]);
    if (showControls) {
      jumpButton.size = Vector2.all(hudSize * 2);
      add(jumpButton);
      addJoystick();
    }
  }

  void loadNextLevel() {
    // TODO LOS NIVELES NO SE ELIMINAN CORREACTAMENTE
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //Game Finished - se vuelve al primer nivel
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    level = Level(levelName: levelNames[currentLevelIndex], player: player);

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
        size: Vector2.all(hudSize),
      ),
      knobRadius: 40,
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('GUI/HUD/Joystick.png')),
        size: Vector2.all(hudSize * 2),
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
}
