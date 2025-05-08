import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import '../../../../pixel_adventure.dart';
import '../utils/number_slider.dart';

// Constantes para definir el tamaño y la posición
const double rowWidth = 475.0;
const double textPositionX = 45.0;
const double sliderPositionX = 20.0;
const double buttonPositionX = 0.0;
const double sliderWidth = 250.0;

class ToggleGameVolumeWidget extends StatefulWidget {
  final PixelAdventure game;
  final Function updateGameVolume;

  ToggleGameVolumeWidget({
    super.key,
    required this.game,
    required this.updateGameVolume,
  });

  @override
  State<ToggleGameVolumeWidget> createState() {
    return _ToggleGameVolumeWidgetState(
      game: game,
      updateGameVolume: updateGameVolume,
    );
  }
}

class _ToggleGameVolumeWidgetState extends State<ToggleGameVolumeWidget> {
  final PixelAdventure game;
  final Function updateGameVolume;

  _ToggleGameVolumeWidgetState({
    required this.game,
    required this.updateGameVolume,
  }) : isSliderActive = game.isGameSoundsActive;

  bool isMuted = false;
  late double value;
  bool isSliderActive;

  Image get volumeImage {
    return game.isGameSoundsActive
        ? Image.asset(
      'assets/images/GUI/HUD/soundOnButton.png',
      fit: BoxFit.cover,
    )
        : Image.asset(
      'assets/images/GUI/HUD/soundOffButton.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rowWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: textPositionX),
          Text('Volume', style: TextStyleSingleton().style),
          SizedBox(width: sliderPositionX),
          SizedBox(
            width: sliderWidth,
            child: NumberSlider(
              game: game,
              value: game.gameSoundVolume * 50,
              onChanged: onChanged,
              isActive: isSliderActive,
            ),
          ),
          SizedBox(width: buttonPositionX),
          IconButton(
            onPressed: changeState,
            icon: volumeImage,
          ),
        ],
      ),
    );
  }

  double? onChanged(dynamic value) {
    if (!game.isGameSoundsActive) {
      return null;
    }

    updateGameVolume(value / 50);
    return value;
  }

  void changeState() {
    setState(() {
      game.isGameSoundsActive = !game.isGameSoundsActive;
      isSliderActive = !isSliderActive;
    });
  }
}
