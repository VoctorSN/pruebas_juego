import 'package:flutter/material.dart';

import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

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

  Image get eyeImage {
    return game.showControls
        ? Image.asset('assets/images/GUI/HUD/openEye.png', fit: BoxFit.cover)
        : Image.asset('assets/images/GUI/HUD/closeEye.png', fit: BoxFit.cover);
  }

  Image get arrowImage {
    return game.isLeftHanded
        ? Image.asset('assets/images/GUI/HUD/arrowsFacingEachother.png', fit: BoxFit.cover)
        : Image.asset('assets/images/GUI/HUD/arrowsFacingEachotherInversed.png', fit: BoxFit.cover);
  }

  // TODO add button to change left handed to right handed

  @override
  Widget build(BuildContext context) {
    value = game.controlSize;

    return Row(
      children: [
        Text('Controls Size', style: TextStyleSingleton().style),
        NumberSlider(game: game, value: value, onChanged: onChanged, isActive: true),
        IconButton(
          onPressed: () {
            setState(() {
              game.showControls = !game.showControls;
              game.reloadAllButtons();
            });
          },
          icon: eyeImage,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              game.isLeftHanded = !game.isLeftHanded;
              game.switchHUDPosition();
            });
          },
          icon: arrowImage,
        ),
      ],
    );
  }

  double? onChanged(dynamic value) {
    updateSizeControls(value);
    return value;
  }
}