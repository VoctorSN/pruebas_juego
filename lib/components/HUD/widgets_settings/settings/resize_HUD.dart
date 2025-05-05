import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

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

  // TODO Add left-hand and right-hand options

  @override
  Widget build(BuildContext context) {

    value = game.hudSize;

    return Row(children: [
      Text('HUD Size',
        style: TextStyleSingleton().style,),
      NumberSlider(game: game, value: value, onChanged: onChanged, isActive: true,),
    ]);
  }

  double? onChanged(dynamic value) {
    updateSizeHUD(value);
    return value;
  }
}