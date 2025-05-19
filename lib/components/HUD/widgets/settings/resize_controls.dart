import 'package:flutter/material.dart';

import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

// TODO: When you press it doesnt depends on applyButton (showControls and leftHanded)
// TODO: You have to press the button isLeftHanded two times to change the image (only pair of times)

const double rowWidth = 475.0;
const double textPositionX = 15.0;
const double sliderPositionX = 0.0;
const double sliderWidth = 250.0;
const double iconSpacing = 0.0;

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
  late bool isLeftHanded = game.settings.showControls;

  Image get eyeImage {
    return game.settings.showControls
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
    return game.settings.isLeftHanded
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
    value = game.settings.controlSize;

    return SizedBox(
      width: rowWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: textPositionX),
          Text(
            'Controls Size',
            style: TextStyleSingleton().style,
          ),
          const SizedBox(width: sliderPositionX),
          SizedBox(
            width: sliderWidth,
            child: NumberSlider(
              game: game,
              value: value,
              onChanged: onChanged,
              isActive: game.settings.showControls,
            ),
          ),
          const SizedBox(width: iconSpacing),
          IconButton(
            onPressed: () {
              setState(() {
                game.settings.showControls = !game.settings.showControls;
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
                game.settings.isLeftHanded = isLeftHanded;
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