import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame/components/HUD/widgets_settings/pause_menu.dart';
import 'package:flutter_flame/components/HUD/widgets_settings/resize_HUD.dart';
import 'package:flutter_flame/components/HUD/widgets_settings/volume_controller_widget.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class SettingsMenu extends StatelessWidget {
  static const String id = 'settings_menu';

  final PixelAdventure game;

  SettingsMenu(this.game, {super.key});

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

                  ToggleVolumeWidget(game: game),

                  ResizeHUD(game: game),

                  ElevatedButton(
                    onPressed: () {
                      game.overlays.remove(SettingsMenu.id);
                      game.overlays.add(PauseMenu.id);
                    },
                    child: const Text('Back'),
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