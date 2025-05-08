import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import '../../../pixel_adventure.dart';

class CharacterSelection extends StatefulWidget {
  static const String id = 'character_selection';

  final PixelAdventure game;

  CharacterSelection(this.game, {super.key});

  @override
  State<CharacterSelection> createState() => _CharacterSelectionState(game: game);
}

class _CharacterSelectionState extends State<CharacterSelection> {
  final PixelAdventure game;

  int selectedIndex = 0;

  final List<String> characterAssets = [
    'assets/images/Main Characters/1/Jump.png',
    'assets/images/Main Characters/2/Jump.png',
    'assets/images/Main Characters/3/Jump.png',
    'assets/images/Main Characters/Mask Dude/Jump.png',
    'assets/images/Main Characters/Ninja Frog/Jump.png',
    'assets/images/Main Characters/Pink Man/Jump.png',
    'assets/images/Main Characters/Virtual Guy/Jump.png',
  ];

  _CharacterSelectionState({required this.game});

  void nextCharacter() {
    setState(() {
      selectedIndex = (selectedIndex + 1) % characterAssets.length;
    });
  }

  void previousCharacter() {
    setState(() {
      selectedIndex = (selectedIndex - 1 + characterAssets.length) % characterAssets.length;
    });
  }

  void selectCharacter() {
    game.overlays.remove(CharacterSelection.id);
    game.resumeEngine();

    game.selectedCharacterIndex(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    // Reusamos los mismos colores del PauseMenu
    const Color baseColor = Color(0xFF212030);
    const Color buttonColor = Color(0xFF3A3750);
    const Color borderColor = Color(0xFF5A5672);
    const Color textColor = Color(0xFFE1E0F5);
    const double avatarSize = 150;

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(220, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderColor, width: 2),
      ),
      elevation: 8,
    );

    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CHARACTER',
                style: TextStyleSingleton().style.copyWith(
                  fontSize: 32,
                  color: textColor,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: avatarSize * 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: previousCharacter,
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 40),
                    ),
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2A3D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          characterAssets[selectedIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: nextCharacter,
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: buttonStyle,
                onPressed: selectCharacter,
                icon: const Icon(Icons.check_circle_outline, color: textColor),
                label: Text(
                  'SELECT',
                  style: TextStyleSingleton().style.copyWith(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
