import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../../../pixel_adventure.dart';
import '../../game/content/levelBasics/player.dart';

class CustomJoystick extends Component with HasGameReference<PixelAdventure> {

  // Constructor and attributes
  final double controlSize;
  CustomJoystick({
    required this.controlSize,
  });

  // Logic to manage the joystick
  late JoystickComponent joystick;
  late Player player = game.player;

  // Logic to manage the update
  static const List<JoystickDirection> movementDirections = [
    JoystickDirection.left,
    JoystickDirection.right,
    JoystickDirection.upLeft,
    JoystickDirection.upRight,
    JoystickDirection.downLeft,
    JoystickDirection.downRight,
  ];
  bool wasIdle = true;



  @override
  Future<void> onLoad() async {
    super.onLoad();
    _addJoystick();
  }

  void _addJoystick() {
    joystick = JoystickComponent(
      priority: 15,
      knob: SpriteComponent(
        sprite: Sprite(game.images.fromCache('GUI/HUD/Knob.png')),
        size: Vector2.all(controlSize),
      ),
      knobRadius: 40,
      background: SpriteComponent(
        sprite: Sprite(game.images.fromCache('GUI/HUD/Joystick.png')),
        size: Vector2.all(controlSize * 2),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    game.add(joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.showControls && movementDirections.contains(joystick.direction)) {
      wasIdle = false;
      _updateJoystick();
    } else if (!wasIdle && joystick.direction == JoystickDirection.idle) {
      wasIdle = true;
      player.horizontalMovement = 0;
      player.isLeftKeyPressed = false;
      player.isRightKeyPressed = false;
    }
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        player.isLeftKeyPressed = true;
        player.isRightKeyPressed = false;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        player.isRightKeyPressed = true;
        player.isLeftKeyPressed = false;
        break;
      default:
        player.horizontalMovement = 0;
        player.isLeftKeyPressed = false;
        player.isRightKeyPressed = false;
        break;
    }
  }
}
