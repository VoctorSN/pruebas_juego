import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../pixel_adventure.dart';
import 'number_slider.dart';

class ResizeJoystick extends StatefulWidget {

  final PixelAdventure game;
  const ResizeJoystick({super.key, required this.game});

  @override
  State<ResizeJoystick> createState() {
    return _ResizeJoystickState(game: game);
  }

}

class _ResizeJoystickState extends State<ResizeJoystick> {

  final PixelAdventure game;
  _ResizeJoystickState({required this.game});

  bool isMuted = false;
  double value = 0.0;
  bool isVisible = true;

  Image get eyeImage {
    return isVisible
        ? Image.asset(
      'assets/images/GUI/HUD/openEye.png',
      fit: BoxFit.cover,
    )
        : Image.asset(
      'assets/images/GUI/HUD/closeEye.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {

    value = game.soundVolume * 50;

    return Row(children: [
      Text('Joystick Size'),
      NumberSlider(game: game, value: value, onChanged: onChanged),
      IconButton(
        onPressed: () {
          setState(() {
            game.showControls = !game.showControls;
            isVisible = !isVisible;
          });
        },
        icon: eyeImage,
      )
    ]);
  }

  double? onChanged(dynamic value) {

    // Lógica para redimensionar el joystick teniendo en cuenta si está visible o no

    // usar game.joystickSize

    if(!game.playSounds){
      return null;
    }

    return value;
  }
}