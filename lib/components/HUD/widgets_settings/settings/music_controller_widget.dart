import 'package:flutter/material.dart';

import '../../../../pixel_adventure.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

class ToggleMusicVolumeWidget extends StatefulWidget {
  final PixelAdventure game;
  Function updateMusicVolume;

  ToggleMusicVolumeWidget({super.key, required this.game, required this.updateMusicVolume});

  @override
  State<ToggleMusicVolumeWidget> createState() {
    return _ToggleMusicVolumeWidgetState(game: game, updateMusicVolume: updateMusicVolume);
  }
}

class _ToggleMusicVolumeWidgetState extends State<ToggleMusicVolumeWidget> {
  final PixelAdventure game;
  Function updateMusicVolume;

  _ToggleMusicVolumeWidgetState({required this.game, required this.updateMusicVolume})
    : isSliderActive = game.isMusicActive;

  bool isMuted = false;
  late double value;
  bool isSliderActive;

  Image get volumeImage {
    return game.isMusicActive
        ? Image.asset('assets/images/GUI/HUD/soundOnButton.png', fit: BoxFit.cover)
        : Image.asset('assets/images/GUI/HUD/soundOffButton.png', fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Music', style: TextStyleSingleton().style),
        NumberSlider(
          game: game,
          value: game.musicSoundVolume * 50, // This value updates dinamically
          onChanged: onChanged,
          isActive: isSliderActive,
        ),

        IconButton(onPressed: changeState, icon: volumeImage),
      ],
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