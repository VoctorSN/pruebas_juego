import 'package:flutter/material.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class NumberSlider extends StatefulWidget {

  final PixelAdventure game;

  const NumberSlider({super.key, required this.game});

  @override
  _NumberSliderState createState()  {
    final sound = game.soundVolume * 50;
    return _NumberSliderState(game:game,variable: sound);
  }
}

class _NumberSliderState extends State<NumberSlider> {

  final PixelAdventure game;
  double variable;

  _NumberSliderState({required this.game, required this.variable});

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SfSlider(
            min: 0.0,
            max: 100.0,
            value: variable,
            interval: 50,
            activeColor: game.playSounds ? Colors.purple : Colors.grey,
            showTicks: true,
            showLabels: false,
            enableTooltip: true,
            minorTicksPerInterval: 1,
            stepSize: 5,
            onChanged: (dynamic value) {
              setState(() {
                if(!game.playSounds){
                  return;
                }
                variable = value;
                game.soundVolume = variable/50;
              });
            },
          )
    );
  }
}