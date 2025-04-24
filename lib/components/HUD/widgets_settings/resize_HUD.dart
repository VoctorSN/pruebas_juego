import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../pixel_adventure.dart';
import '../style/text_style_singleton.dart';
import 'number_slider.dart';

class ResizeHUD extends StatefulWidget {

  final PixelAdventure game;
  Function updateSizeHUD;
  ResizeHUD({super.key, required this.game, required this.updateSizeHUD});

  @override
  State<ResizeHUD> createState() {
    return _ResizeHUDState(game: game, updateSizeHUD: updateSizeHUD);
  }

}

class _ResizeHUDState extends State<ResizeHUD> {

  final PixelAdventure game;
  Function updateSizeHUD;
  _ResizeHUDState({required this.game, required this.updateSizeHUD});

  late double value;
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

  // TODO Añadir el modo para zurdos y diestros

  @override
  Widget build(BuildContext context) {

    value = game.hudSize;

    return Row(children: [
      Text('HUD Size',
        style: TextStyleSingleton().style,),
      NumberSlider(game: game, value: value, onChanged: onChanged, isActive: true,),
      IconButton(
        onPressed: () {
          // Dejar este botón o sacarlo?
          // Hacer que con este botón los botones del HUD (solo los de la pantalla) se oculten
        },
        icon: eyeImage,
      )
    ]);
  }

  double? onChanged(dynamic value) {
    updateSizeHUD(value);
    return value;
  }
}