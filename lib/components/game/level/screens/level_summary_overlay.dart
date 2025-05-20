import 'package:flutter/material.dart';

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
        // Fondo semitransparente para mayor contraste
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
        Center(
          child: Container(
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
                Text(
                  levelName,
                  style: textStyle.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _infoRow(Icons.whatshot, 'Dificultad', '★' * difficulty, textStyle),
                _infoRow(Icons.sell, 'Muertes', '$deaths', textStyle),
                _infoRow(Icons.star, 'Estrellas', '$stars', textStyle),
                _infoRow(Icons.timer, 'Tiempo', '${(time / 1000).toStringAsFixed(2)}s', textStyle),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ArcadeClassic',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text('$label: ', style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
