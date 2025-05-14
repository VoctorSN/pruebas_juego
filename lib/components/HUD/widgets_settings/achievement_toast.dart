import 'package:flutter/material.dart';
import 'package:fruit_collector/components/bbdd/achievement.dart';

/// TODO add styles
class AchievementToast extends StatelessWidget {

  static const String id = 'achievement_toast';

  // Constructor and attributes
  final Achievement achievement;
  const AchievementToast({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Logro desbloqueado!',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              achievement.description,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}