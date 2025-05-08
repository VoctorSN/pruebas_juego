import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

// Constantes para definir el tamaño y la posición
const double rowWidth = 465.0;
const double textPositionX = 5.0;
const double sliderPositionX = 0.0;
const double sliderWidth = 250.0;
const double iconSpacing = 10.0;

class ResizeControls extends StatefulWidget {
  final PixelAdventure game;
  final Function updateSizeControls;

  ResizeControls({
    super.key,
    required this.game,
    required this.updateSizeControls,
  });

  @override
  State<ResizeControls> createState() {
    return _ResizeControlsState(
      game: game,
      updateSizeControls: updateSizeControls,
    );
  }
}

class _ResizeControlsState extends State<ResizeControls> {
  final PixelAdventure game;
  final Function updateSizeControls;

  _ResizeControlsState({
    required this.game,
    required this.updateSizeControls,
  });

  late double value;
  bool isLeftHanded = false;

  Image get eyeImage {
    return game.showControls
        ? Image.asset(
      'assets/images/GUI/HUD/openEye.png',
      fit: BoxFit.cover,
    )
        : Image.asset(
      'assets/images/GUI/HUD/closeEye.png',
      fit: BoxFit.cover,
    );
  }

  Image get arrowImage {
    return game.isLeftHanded
        ? Image.asset(
      'assets/images/GUI/HUD/arrowsFacingEachother.png',
      fit: BoxFit.cover,
    )
        : Image.asset(
      'assets/images/GUI/HUD/arrowsFacingEachotherInversed.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    value = game.controlSize;

    return SizedBox(
      width: rowWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: textPositionX),
          Text(
            'Controls Size',
            style: TextStyleSingleton().style,
          ),
          SizedBox(width: sliderPositionX),
          SizedBox(
            width: sliderWidth,
            child: NumberSlider(
              game: game,
              value: value,
              onChanged: onChanged,
              isActive: true,
            ),
          ),
          const SizedBox(width: iconSpacing),
          IconButton(
            onPressed: () {
              setState(() {
                game.showControls = !game.showControls;
                game.reloadAllButtons();
              });
            },
            icon: eyeImage,
          ),
          const SizedBox(width: iconSpacing),
          IconButton(
            onPressed: () {
              setState(() {
                isLeftHanded = !isLeftHanded;
                game.isLeftHanded = isLeftHanded;
                game.switchHUDPosition();
              });
            },
            icon: arrowImage,
          ),
        ],
      ),
    );
  }

  double? onChanged(dynamic value) {
    updateSizeControls(value);
    return value;
  }
}
