import 'package:flutter/material.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class NumberSlider extends StatefulWidget {

  final PixelAdventure game;
  final double value;
  final Function(dynamic) onChanged;

  const NumberSlider(
      {super.key, required this.game, required this.value, required this.onChanged});

  @override
  _NumberSliderState createState() {
    //final sound = game.soundVolume * 50;
    return _NumberSliderState(game: game, value: value, onChanged: onChanged);
  }
}

class _NumberSliderState extends State<NumberSlider> {

  final PixelAdventure game;
  double value;
  Function(dynamic) onChanged;

  _NumberSliderState(
      {required this.game, required this.value, required this.onChanged});

  set setValue(double newValue) {
    setState(() {
      value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SfSlider(
          min: 0.0,
          max: 100.0,
          value: value,
          interval: 50,
          activeColor: game.playSounds ? Colors.purple : Colors.grey,
          showTicks: true,
          showLabels: false,
          enableTooltip: true,
          minorTicksPerInterval: 1,
          stepSize: 5,
          onChanged: (dynamic newValue) {
            setState(() {
              // Se le asigna el valor que devuelve la función onChanged y si es null el valor no se cambia simulando que el slider no se mueve
              value = onChanged(newValue) ?? value;
            });
          },
        )
    );
  }
}