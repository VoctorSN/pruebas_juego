import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import '../../../../pixel_adventure.dart';
import '../level_selection_menu.dart';

/// TODO extract the background and add a if to pc or mobile to move the buttons and title
class MainMenu extends StatefulWidget {
  static const String id = 'MainMenu';
  final PixelAdventure game;

  const MainMenu(this.game, {super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  final List<String> gifPaths = List.generate(
    7,
        (i) => 'assets/gifsMainMenu/gif${i + 1}.gif',
  );
  int _currentGif = 0;
  late Timer _gifTimer;
  late AnimationController _logoController;

  final Color baseColor = const Color(0xFF212030);
  final Color buttonColor = const Color(0xFF3A3750);
  final Color borderColor = const Color(0xFF5A5672);
  final Color textColor = const Color(0xFFE1E0F5);

  late final ButtonStyle buttonStyle;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _gifTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        _currentGif = (_currentGif + 1) % gifPaths.length;
      });
    });

    buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(220, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 8,
    );
  }

  @override
  void dispose() {
    _gifTimer.cancel();
    _logoController.dispose();
    super.dispose();
  }

  Widget _menuButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: buttonStyle,
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyleSingleton().style.copyWith(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background made of gifs
        Positioned.fill(
          child: Image.asset(gifPaths[_currentGif], fit: BoxFit.cover),
        ),

        // Made the background a bit translucent
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: baseColor.withOpacity(0.4)),
          ),
        ),

        // Title and buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 18,
          left: 34,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(
                scale: _logoController,
                child: Text(
                  'FRUIT COLLECTOR',
                  style: TextStyleSingleton().style.copyWith(
                    fontSize: 48,
                    color: textColor,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _menuButton('NEW GAME', Icons.play_arrow, () {
                widget.game.overlays.remove(MainMenu.id);
                widget.game.resumeEngine();
              }),
              const SizedBox(height: 12),
              _menuButton('LEVELS', Icons.map, () {
                widget.game.overlays.remove(MainMenu.id);
                widget.game.overlays.add(LevelSelectionMenu.id);
              }),
              const SizedBox(height: 12),
              _menuButton('SETTINGS', Icons.settings, () {
                // TODO open settings menu (with the data from the bbdd)
                // open settings (with gif background) and come back to menu
              }),
              const SizedBox(height: 12),
              _menuButton('QUIT', Icons.exit_to_app, () {
                FlameAudio.bgm.stop();
                SystemNavigator.pop();
              }),
            ],
          ),
        ),
      ],
    );
  }
}