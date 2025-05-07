import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class CustomJoystick extends JoystickComponent {
  final void Function(JoystickDirection)? onDirectionChanged;
  final VoidCallback? onReleased;

  CustomJoystick({
    required SpriteComponent knob,
    required SpriteComponent background,
    required double knobRadius,
    this.onDirectionChanged,
    this.onReleased,
    EdgeInsets? margin,
    int priority = 0,
  }) : super(
    knob: knob,
    background: background,
    knobRadius: knobRadius,
    margin: margin,
    priority: priority,
  );

  static final List<JoystickDirection> movementDirections = [
    JoystickDirection.left,
    JoystickDirection.right,
    JoystickDirection.upLeft,
    JoystickDirection.upRight,
    JoystickDirection.downLeft,
    JoystickDirection.downRight,
  ];
  bool wasStill = true;

  @override
  void update(double dt) {

    // if (!wasStill &&  !movementDirections.contains(direction)) {
    //   print("cambiamos a wasStill");
    //   wasStill = true;
    // }else if (wasStill && !movementDirections.contains(direction)) {
    //   print("nos vamos rapido");
    // }else{
    //   wasStill = false;
    //   print("moviendose ${direction}");
    // }
    // print("update");
    super.update(dt);
  }
}