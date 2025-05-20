import 'package:flutter/material.dart';

import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

const double rowWidth = 475.0;
const double textPositionX = 15.0;
const double sliderPositionX = 0.0;
const double sliderWidth = 250.0;
const double iconSpacing = 0.0;

class ResizeControls extends StatefulWidget {
  final PixelAdventure game;
  final Function updateSizeControls;
  final Function updateIsLeftHanded;
  final Function updateShowControls;

  ResizeControls({
    super.key,
    required this.game,
    required this.updateSizeControls,
    required this.updateIsLeftHanded,
    required this.updateShowControls,
  });

  @override
  State<ResizeControls> createState() {
    return _ResizeControlsState(
      game: game,
      updateSizeControls: updateSizeControls,
      updateIsLeftHanded: updateIsLeftHanded,
      updateShowControls: updateShowControls,
    );
  }
}

class _ResizeControlsState extends State<ResizeControls> {
  final PixelAdventure game;
  final Function updateSizeControls;
  final Function updateIsLeftHanded;
  final Function updateShowControls;

  _ResizeControlsState({
    required this.game,
    required this.updateSizeControls,
    required this.updateIsLeftHanded,
    required this.updateShowControls,
  });

  late double value;
  late bool isLeftHanded = game.settings.isLeftHanded;
  late bool showControls = game.settings.showControls;

  Image get eyeImage {
    return showControls
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
    return isLeftHanded
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
              isActive: showControls,
              minValue: 15.0,
            ),
          ),
          const SizedBox(width: iconSpacing),
          IconButton(
            onPressed: () {
              setState(() {
                showControls = !showControls;
                updateShowControls(showControls);
              });
            },
            icon: eyeImage,
          ),
          const SizedBox(width: iconSpacing),
          IconButton(
            onPressed: () {
              setState(() {
                isLeftHanded = !isLeftHanded;
                updateIsLeftHanded(isLeftHanded);
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