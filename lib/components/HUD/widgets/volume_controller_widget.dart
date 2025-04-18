import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flame/components/HUD/widgets/number_slider.dart';

import '../../../pixel_adventure.dart';

class ToggleVolumeWidget extends StatefulWidget {

  final PixelAdventure game;
  const ToggleVolumeWidget({super.key, required this.game});

  @override
  State<ToggleVolumeWidget> createState() {
    return _ToggleVolumeWidgetState(game: game);
  }

}

class _ToggleVolumeWidgetState extends State<ToggleVolumeWidget> {

  final PixelAdventure game;
  _ToggleVolumeWidgetState({required this.game});

  bool isMuted = false;

  Image get volumeImage {
    return game.playSounds
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
    return Row(children: [
      NumberSlider(game: game, enabled: game.playSounds),
      IconButton(
      onPressed: () {
        setState(() {
          game.playSounds = !game.playSounds;
        });
      },
      icon: volumeImage,
    )
    ]);
  }
}