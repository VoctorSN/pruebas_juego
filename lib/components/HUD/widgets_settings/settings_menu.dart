import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/pause_menu.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/resize_HUD.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/resize_controls.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/volume_controller_widget.dart';
import '../../../pixel_adventure.dart';

class SettingsMenu extends StatelessWidget {
  static const String id = 'settings_menu';

  final PixelAdventure game;

  SettingsMenu(this.game, {super.key});

  late double sizeHUD = game.hudSize;
  late double sizeControls = game.controlSize;
  late double volume = game.soundVolume;

  updateSizeHUD(double newValue) {
    sizeHUD = newValue;
  }

  updateSizeControls(double newValue) {
    sizeControls = newValue;
  }

  updateVolume(double newValue) {
    volume = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.black.withAlpha(100),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 60,
                horizontal: 100,
              ),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontFamily: 'Audiowide',
                      ),
                    ),
                  ),

                  ToggleVolumeWidget(game: game, updateVolume: updateVolume),

                  ResizeHUD(game: game, updateSizeHUD: updateSizeHUD),

                  ResizeControls(game: game, updateSizeControls: updateSizeControls),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          game.overlays.remove(SettingsMenu.id);
                          game.overlays.add(PauseMenu.id);
                        },
                        child: const Text('Back'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          game.overlays.remove(SettingsMenu.id);
                          game.overlays.add(PauseMenu.id);

                          // Apply size changes
                          game.hudSize = sizeHUD;
                          game.controlSize = sizeControls;
                          game.reloadAllButtons();

                          // Apply volume changes
                          game.soundVolume = volume;
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}