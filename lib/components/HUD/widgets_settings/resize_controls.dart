import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../pixel_adventure.dart';
import '../style/text_style_singleton.dart';
import 'number_slider.dart';

class ResizeControls extends StatefulWidget {

  final PixelAdventure game;
  Function updateSizeControls;
  ResizeControls({super.key, required this.game, required this.updateSizeControls});

  @override
  State<ResizeControls> createState() {
    return _ResizeControlsState(game: game, updateSizeControls: updateSizeControls);
  }

}

class _ResizeControlsState extends State<ResizeControls> {

  final PixelAdventure game;
  Function updateSizeControls;
  _ResizeControlsState({required this.game, required this.updateSizeControls});

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

    value = game.controlSize;

    return Row(children: [
      Text('Controls Size',
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
    updateSizeControls(value);
    return value;
  }
}