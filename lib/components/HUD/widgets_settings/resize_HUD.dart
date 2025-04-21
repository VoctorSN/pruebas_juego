import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../pixel_adventure.dart';
import 'number_slider.dart';

class ResizeHUD extends StatefulWidget {

  final PixelAdventure game;
  const ResizeHUD({super.key, required this.game});

  @override
  State<ResizeHUD> createState() {
    return _ResizeHUDState(game: game);
  }

}

class _ResizeHUDState extends State<ResizeHUD> {

  final PixelAdventure game;
  _ResizeHUDState({required this.game});

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

    value = game.hudSize;

    return Row(children: [
      Text('HUD Size'),
      NumberSlider(game: game, value: value, onChanged: onChanged),
      IconButton(
        onPressed: () {
          setState(() {
            game.showControls = !game.showControls;
            isVisible = game.showControls;
          });
        },
        icon: eyeImage,
      )
    ]);
  }

  double? onChanged(dynamic value) {

    // Lógica para redimensionar el joystick teniendo en cuenta si está visible o no

    if(!game.playSounds){
      return null;
    }

    game.hudSize = value;
    game.joystick.removeFromParent();
    game.addJoystick();

    return value;
  }
}