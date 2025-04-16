import 'package:flutter/material.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class NumberSlider extends StatefulWidget {

  final PixelAdventure game;
  final bool isSliderEnabled;

  const NumberSlider({super.key, required this.game, this.isSliderEnabled = true, required enabled});

  @override
  _NumberSliderState createState()  {
    final sound = game.soundVolume * 50;
    return _NumberSliderState(game:game,soundVolume: sound, isSliderEnabled: isSliderEnabled);
  }
}

class _NumberSliderState extends State<NumberSlider> {

  final PixelAdventure game;
  double soundVolume;
  bool isSliderEnabled;

  _NumberSliderState({required this.game, required this.soundVolume, this.isSliderEnabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SfSlider(
            min: 0.0,
            max: 100.0,
            value: soundVolume,
            interval: 50,
            activeColor: isSliderEnabled ? Colors.purple : Colors.grey,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            minorTicksPerInterval: 1,
            stepSize: 5,
            onChanged: (dynamic value) {
              setState(() {
                if(!isSliderEnabled){
                  return;
                }
                soundVolume = value;
                game.soundVolume = soundVolume/50;
              });
            },
          )
    );
  }
}