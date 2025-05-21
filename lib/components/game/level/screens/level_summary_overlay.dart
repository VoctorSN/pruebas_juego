import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// TODO: centrar bien los datos
/// TODO: cargar los datos correctamente
/// TODO: hacer q también funcione cuando se selecciona un nivel
/// TODO: no se supone que tiene que cargar el siguiente level? o simplemente es un resumen?, yo lo haría como cambio de nivel y ya
class LevelSummaryOverlay extends StatelessWidget {
  final String levelName;
  final int difficulty;
  final int deaths;
  final int stars;
  final int time; // En milisegundos
  final VoidCallback onContinue;

  const LevelSummaryOverlay({
    super.key,
    required this.levelName,
    required this.difficulty,
    required this.deaths,
    required this.stars,
    required this.time,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontFamily: 'ArcadeClassic',
      fontWeight: FontWeight.bold,
    );

    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.7)),
        Center(
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(levelName, style: textStyle.copyWith(fontSize: 24), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _infoRow(icon: Icons.whatshot, label: 'Difficulty', value: '★' * difficulty, style: textStyle),
                _infoRow(icon: FontAwesomeIcons.skullCrossbones, label: 'Deaths', value: '$deaths', style: textStyle),
                _infoRow(icon: Icons.timer, label: 'Time', value: _formatTime(time), style: textStyle),
                _infoRow(icon: Icons.star, label: 'Stars', value: '$stars', style: textStyle),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'ArcadeClassic'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value, required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Columna izquierda: icono + etiqueta, alineado a la derecha
          SizedBox(
            width: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text('$label:', style: style, textAlign: TextAlign.right),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Columna derecha: valor alineado a la izquierda
          SizedBox(
            width: 120,
            child: Text(value, style: style, textAlign: TextAlign.left, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatTime(int milliseconds) {
    final int seconds = (milliseconds / 1000).round();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String paddedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }
}