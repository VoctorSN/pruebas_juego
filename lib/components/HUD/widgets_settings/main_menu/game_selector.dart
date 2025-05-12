import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import '../../../../pixel_adventure.dart';
import 'background_gif.dart';
import 'main_menu.dart';

class GameSelector extends StatelessWidget {
  static const String id = 'GameSelector';
  final PixelAdventure game;

  const GameSelector(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF212030);
    final Color buttonColor = const Color(0xFF3A3750);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(220, 48),
      maximumSize: const Size(250, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 6,
    );

    final ButtonStyle backButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: baseColor.withOpacity(0.7),
      foregroundColor: textColor,
      minimumSize: const Size(140, 40),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 1),
      ),
      elevation: 4,
    );

    final double topPadding = MediaQuery.of(context).padding.top + 18;

    return Stack(
      fit: StackFit.expand,
      children: [
        const BackgroundWidget(),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 400,
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SELECT SAVE SLOT',
                      textAlign: TextAlign.center,
                      style: TextStyleSingleton().style.copyWith(
                        fontSize: 32,
                        color: textColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _slotButton(
                      label: 'SAVE SLOT 1 - Level 3',
                      icon: Icons.insert_drive_file,
                      onPressed: () => _loadSlot(1, context),
                      style: buttonStyle,
                      textColor: textColor,
                      isEmpty: false,
                    ),
                    const SizedBox(height: 5),
                    _slotButton(
                      label: 'SAVE SLOT 2 - Level 1',
                      icon: Icons.insert_drive_file,
                      onPressed: () => _loadSlot(2, context),
                      style: buttonStyle,
                      textColor: textColor,
                      isEmpty: false,
                    ),
                    const SizedBox(height: 5),
                    _slotButton(
                      label: 'Empty',
                      icon: Icons.insert_drive_file_outlined,
                      onPressed: () => _loadSlot(3, context),
                      style: buttonStyle,
                      textColor: textColor,
                      isEmpty: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        game.overlays.remove(GameSelector.id);
                        game.overlays.add(MainMenu.id);
                      },
                      style: backButtonStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'BACK',
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _slotButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required ButtonStyle style,
    required Color textColor,
    required bool isEmpty,
  }) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyleSingleton().style.copyWith(
                fontSize: 14,
                color: textColor.withOpacity(isEmpty ? 0.4 : 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _loadSlot(int slot, BuildContext context) {
    // TODO (BBDD) -> Load actual saved game state here
    game.overlays.remove(GameSelector.id);
    game.resumeEngine();
  }
}
