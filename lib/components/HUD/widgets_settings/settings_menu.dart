import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/music_controller_widget.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/pause_menu.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/resize_HUD.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/resize_controls.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/game_volume_controller_widget.dart';
import '../../../pixel_adventure.dart';
import '../style/text_style_singleton.dart';

class SettingsMenu extends StatelessWidget {
  static const String id = 'settings_menu';

  final PixelAdventure game;

  SettingsMenu(this.game, {super.key});

  late double sizeHUD = game.hudSize;
  late double sizeControls = game.controlSize;
  late double gameVolume = game.gameSoundVolume;
  late double musicVolume = game.musicSoundVolume;

  updateSizeHUD(double newValue) {
    sizeHUD = newValue;
  }

  updateSizeControls(double newValue) {
    sizeControls = newValue;
  }

  updateMusicVolume(double newValue) {
    musicVolume = newValue;
  }

  updateGameVolume(double newValue) {
    gameVolume = newValue;
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
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Settings',
                      style: TextStyleSingleton().style.copyWith(fontSize : 50),
                    ),
                  ),

                  ToggleMusicVolumeWidget(
                    game: game,
                    updateMusicVolume: updateMusicVolume,
                  ),

                  ToggleGameVolumeWidget(
                    game: game,
                    updateGameVolume: updateGameVolume,
                  ),

                  ResizeHUD(game: game, updateSizeHUD: updateSizeHUD),

                  ResizeControls(
                    game: game,
                    updateSizeControls: updateSizeControls,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          game.overlays.remove(SettingsMenu.id);
                          game.overlays.add(PauseMenu.id);
                        },
                        child: Text(
                          'Back',
                            style: TextStyleSingleton().style.copyWith(color: Colors.purple),

                        ),
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
                          game.gameSoundVolume = gameVolume;
                          game.musicSoundVolume = musicVolume;
                        },
                        child: Text(
                          'Apply',
                          style: TextStyleSingleton().style.copyWith(color: Colors.purple),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
