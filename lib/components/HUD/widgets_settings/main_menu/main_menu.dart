import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import '../../../../pixel_adventure.dart';
import '../character_selecition.dart';
import '../settings/settings_menu.dart';

class MainMenu extends StatelessWidget {
  static const String id = 'MainMenu';
  final PixelAdventure game;

  MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta Stardew-like oscura
    const baseColor = Color(0xFF212030);
    const panelColor = Color(0xFF2B2A3D);
    const borderColor = Color(0xFF5A5672);
    const textColor = Color(0xFFE1E0F5);

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: panelColor,
      foregroundColor: textColor,
      minimumSize: const Size(240, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: borderColor, width: 3),
      ),
      elevation: 4,
    );

    return Stack(
      children: [
        // 1) Fondo completo (puede ser una imagen de tu juego o un color)
        Positioned.fill(
          child: Image.asset(
            'assets/images/menu_background.png', // tu imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        // 2) Overlay borroso
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: baseColor.withOpacity(0.3)),
          ),
        ),
        // 3) Panel central
        Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: panelColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'FRUIT COLLECTOR',
                  textAlign: TextAlign.center,
                  style: TextStyleSingleton().style.copyWith(
                    fontSize: 32,
                    color: textColor,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones estilo Stardew
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    game.overlays.remove(MainMenu.id);
                    game.overlays.add(CharacterSelection.id);
                    game.pauseEngine();
                  },
                  child: Text(
                    'NEW GAME',
                    style: TextStyleSingleton().style.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    // Continuar lógica de carga si existe
                  },
                  child: Text(
                    'CONTINUE',
                    style: TextStyleSingleton().style.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    game.overlays.remove(MainMenu.id);
                    game.overlays.add(SettingsMenu.id);
                  },
                  child: Text(
                    'SETTINGS',
                    style: TextStyleSingleton().style.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    // Salir de la app
                    FlameAudio.bgm.stop();
                    // SystemNavigator.pop(); // O exit(0);
                  },
                  child: Text(
                    'QUIT',
                    style: TextStyleSingleton().style.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
