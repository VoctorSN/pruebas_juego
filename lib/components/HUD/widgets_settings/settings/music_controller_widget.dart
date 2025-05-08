import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

// Constantes para definir el tamaño y la posición
const double rowWidth = 475.0;
const double textPositionX = 50.0;
const double sliderPositionX = 23.0;
const double buttonPositionX = .0;
const double sliderWidth = 250.0;

class ToggleMusicVolumeWidget extends StatefulWidget {
  final PixelAdventure game;
  final Function updateMusicVolume;

  ToggleMusicVolumeWidget({
    super.key,
    required this.game,
    required this.updateMusicVolume,
  });

  @override
  State<ToggleMusicVolumeWidget> createState() {
    return _ToggleMusicVolumeWidgetState(
      game: game,
      updateMusicVolume: updateMusicVolume,
    );
  }
}

class _ToggleMusicVolumeWidgetState extends State<ToggleMusicVolumeWidget> {
  final PixelAdventure game;
  final Function updateMusicVolume;

  _ToggleMusicVolumeWidgetState({
    required this.game,
    required this.updateMusicVolume,
  }) : isSliderActive = game.isMusicActive;

  bool isMuted = false;
  late double value;
  bool isSliderActive;

  Image get volumeImage {
    return game.isMusicActive
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
          Text(
            'Music',
            style: TextStyleSingleton().style,
          ),
          SizedBox(width: sliderPositionX),
          SizedBox(
            width: sliderWidth,
            child: NumberSlider(
              game: game,
              value: game.musicSoundVolume * 50,
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
    if (!game.isMusicActive) {
      return null;
    }

    updateMusicVolume(value / 50);
    return value;
  }

  void changeState() {
    setState(() {
      game.isMusicActive = !game.isMusicActive;
      isSliderActive = !isSliderActive;
    });
  }
}
