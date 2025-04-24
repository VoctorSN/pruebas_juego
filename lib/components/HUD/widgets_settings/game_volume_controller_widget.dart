import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../pixel_adventure.dart';
import 'number_slider.dart';

class ToggleGameVolumeWidget extends StatefulWidget {
  final PixelAdventure game;
  Function updateGameVolume;

  ToggleGameVolumeWidget({
    super.key,
    required this.game,
    required this.updateGameVolume,
  });

  @override
  State<ToggleGameVolumeWidget> createState() {
    return _ToggleGameVolumeWidgetState(game: game, updateGameVolume: updateGameVolume);
  }
}

class _ToggleGameVolumeWidgetState extends State<ToggleGameVolumeWidget> {
  final PixelAdventure game;
  Function updateGameVolume;

  _ToggleGameVolumeWidgetState({required this.game, required this.updateGameVolume})
      : isSliderActive = game.isGameSoundsActive;

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
    return Row(
      children: [
        Text('Volume'),
        NumberSlider(
          game: game,
          value: game.gameSoundVolume * 50, // Actualiza dinámicamente el valor
          onChanged: onChanged,
          isActive: isSliderActive,
        ),

        IconButton(
          onPressed: changeState,
          icon: volumeImage,
        ),
      ],
    );
  }

  double? onChanged(dynamic value) {
    if (!game.isGameSoundsActive) {
      return null;
    }

      updateGameVolume(value/50);
      return value;
  }

  void changeState() {
    setState(() {
      game.isGameSoundsActive = !game.isGameSoundsActive;
      isSliderActive = !isSliderActive;
    });
  }
}
