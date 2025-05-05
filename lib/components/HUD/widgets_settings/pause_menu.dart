import 'dart:ui';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets_settings/settings_menu.dart';
import '../../../pixel_adventure.dart';
import '../style/text_style_singleton.dart';class PauseMenu extends StatelessWidget {

  static String id = 'PauseMenu';

  final PixelAdventure game;

  PauseMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    FlameAudio.bgm.stop();

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(200, 50),
      textStyle: const TextStyle(fontSize: 18),
    );

    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.black.withAlpha(100),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 60, horizontal: 100),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'PAUSED',
                      style: TextStyleSingleton().style.copyWith(fontSize: 50),
                    ),
                  ),
                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      game.overlays.remove(PauseMenu.id);
                      game.resumeEngine();
                      if (game.isMusicActive) FlameAudio.bgm.play('background_music.mp3',volume: game.musicSoundVolume);
                    },
                    child: Text('Resume',
                        style: TextStyleSingleton().style.copyWith(color: Colors.purple),
                    ),
                  ),

                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      game.overlays.remove(PauseMenu.id);
                      game.overlays.add(SettingsMenu.id);
                    },
                    child: Text('Settings',
                      style: TextStyleSingleton().style.copyWith(color: Colors.purple),),
                  ),

                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      print("Ir al menú principal estilo stardew valley");
                    },
                    child: Text('Main Menu',
                      style: TextStyleSingleton().style.copyWith(color: Colors.purple),),
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