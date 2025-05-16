import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../pixel_adventure.dart';

class NumberSlider extends StatefulWidget {
  final PixelAdventure game;
  final double value;
  final Function(dynamic) onChanged;
  final bool isActive;

  const NumberSlider({super.key, required this.game, required this.value, required this.onChanged, required this.isActive});

  @override
  _NumberSliderState createState() {
    return _NumberSliderState(game: game, value: value, onChanged: onChanged, isActive: isActive);
  }
}

class _NumberSliderState extends State<NumberSlider> {
  final PixelAdventure game;
  double value;
  Function(dynamic) onChanged;
  bool isActive;

  _NumberSliderState({required this.game, required this.value, required this.onChanged, required this.isActive});

  set setValue(double newValue) {
    setState(() {
      value = newValue;
    });
  }

  @override
  void didUpdateWidget(covariant NumberSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      setState(() {
        isActive = widget.isActive;
      });
    }
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
        activeColor: isActive ? Colors.purple : Colors.grey,
        showTicks: true,
        showLabels: false,
        enableTooltip: true,
        minorTicksPerInterval: 1,
        stepSize: 5,
        onChanged: (dynamic newValue) {
          setState(() {
            value = onChanged(newValue) ?? value;
          });
        },
      ),
    );
  }
}