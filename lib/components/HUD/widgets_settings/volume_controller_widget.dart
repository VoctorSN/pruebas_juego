import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../pixel_adventure.dart';
import 'number_slider.dart';

class ToggleVolumeWidget extends StatefulWidget {

  final PixelAdventure game;
  Function updateVolume;
  ToggleVolumeWidget({super.key, required this.game, required this.updateVolume});

  @override
  State<ToggleVolumeWidget> createState() {
    return _ToggleVolumeWidgetState(game: game, updateVolume: updateVolume);
  }

}

class _ToggleVolumeWidgetState extends State<ToggleVolumeWidget> {

  final PixelAdventure game;
  Function updateVolume;
  _ToggleVolumeWidgetState({required this.game, required this.updateVolume});

  bool isMuted = false;
  late double value;

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

    value = game.soundVolume * 50;

    return Row(children: [
      Text('Volume'),
      NumberSlider(game: game, value: value, onChanged: onChanged),
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

  double? onChanged(dynamic value) {
      if(!game.playSounds){
        return null;
      }

      updateVolume(value/50);
      return value;
  }
}