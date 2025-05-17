import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../pixel_adventure.dart';
import '../../../bbdd/models/game.dart';
import '../../../bbdd/services/game_service.dart';
import 'background_gif.dart';
import 'main_menu.dart';

class GameSelector extends StatefulWidget {
  static const String id = 'GameSelector';
  final PixelAdventure game;

  const GameSelector(this.game, {super.key});

  @override
  State<GameSelector> createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  Game? slot1;
  Game? slot2;
  Game? slot3;

  GameService? gameService;

  @override
  void initState(){
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    await getGameService();
    slot1 = await gameService!.getGameBySpace(space: 1);
    slot2 = await gameService!.getGameBySpace(space: 2);
    slot3 = await gameService!.getGameBySpace(space: 3);
    if (mounted) {
      setState(() {});
    }
  }

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
                      'SELECT  SAVE  SLOT',
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
                    _buildSlot(slot1, 1, buttonStyle, textColor),
                    const SizedBox(height: 5),
                    _buildSlot(slot2, 2, buttonStyle, textColor),
                    const SizedBox(height: 5),
                    _buildSlot(slot3, 3, buttonStyle, textColor),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        widget.game.overlays.remove(GameSelector.id);
                        widget.game.overlays.add(MainMenu.id);
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

  Widget _buildSlot(
    Game? game,
    int slotNumber,
    ButtonStyle style,
    Color textColor,
  ) {
    final isEmpty = game == null;
    final label = isEmpty
        ? 'Empty'
        : 'SAVE SLOT $slotNumber - Level ${game.currentLevel + 1}';
    final icon = isEmpty
        ? Icons.insert_drive_file_outlined
        : Icons.insert_drive_file;

    return _slotButton(
      label: label,
      icon: icon,
      onPressed: () => _loadSlot(slotNumber, context),
      style: style,
      textColor: textColor,
      isEmpty: isEmpty,
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

  void _loadSlot(int slot, BuildContext context) async {
    await widget.game.chargeSlot(slot);
    widget.game.overlays.remove(GameSelector.id);
    widget.game.resumeEngine();
  }

  Future<void> getGameService() async{
    gameService ??= await GameService.getInstance();
  }
}