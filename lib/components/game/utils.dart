import 'package:flame/collisions.dart';
import 'package:flutter_flame/components/game/spawnpoints/enemies/chicken.dart';
import 'package:flutter_flame/components/game/spawnpoints/levelContent/player.dart';

bool checkCollision(Player player, block) {
  final hitbox = player.hitbox;

  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX*2) - playerWidth : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return(
      fixedY < blockY + blockHeight &&
          playerY + playerHeight > blockY &&
          fixedX < blockX + blockWidth &&
          fixedX + playerWidth > blockX
  );
}

bool checkCollisionChicken(Chicken chicken, block) {

  final playerX = chicken.position.x;
  final playerY = chicken.position.y;
  final playerWidth = chicken.width;
  final playerHeight = chicken.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  return(
      playerY < blockY + blockHeight &&
          playerY + playerHeight > blockY &&
          playerX < blockX + blockWidth &&
          playerX + playerWidth > blockX
  );
}

bool isPlayerInsideBlock(Player player, RectangleHitbox blockHitbox) {
  final playerHitbox = player.hitbox;

  // Calcular la posición del hitbox en función de la dirección
  final baseX = player.position.x + playerHitbox.offsetX;
  final adjustedPlayerLeft = player.scale.x < 0
      ? baseX - (playerHitbox.offsetX * 2) - playerHitbox.width
      : baseX;
  final adjustedPlayerRight = adjustedPlayerLeft + playerHitbox.width;

  final playerTop = player.position.y + playerHitbox.offsetY;
  final playerBottom = playerTop + playerHitbox.height;

  final blockLeft = blockHitbox.absolutePosition.x;
  final blockRight = blockLeft + blockHitbox.size.x;
  final blockTop = blockHitbox.absolutePosition.y;
  final blockBottom = blockTop + blockHitbox.size.y;

  // Calcular la superposición horizontal
  final horizontalOverlap = (adjustedPlayerRight > blockLeft && adjustedPlayerLeft < blockRight);

  // Calcular la superposición vertical
  final verticalOverlap = (playerBottom > blockTop && playerTop < blockBottom);

  // Devolver true solo si hay superposición horizontal y vertical
  return horizontalOverlap && verticalOverlap;
}


void movePlayerNextToBlock(Player player, RectangleHitbox blockHitbox) {
  final playerHitbox = player.hitbox;

  // Calcular la posición del hitbox en función de la dirección
  final baseX = player.position.x + playerHitbox.offsetX;
  final adjustedPlayerLeft = player.scale.x < 0
      ? baseX - (playerHitbox.offsetX * 2) - playerHitbox.width
      : baseX;
  final adjustedPlayerRight = adjustedPlayerLeft + playerHitbox.width;

  final playerTop = player.position.y + playerHitbox.offsetY;
  final playerBottom = playerTop + playerHitbox.height;

  final blockLeft = blockHitbox.absolutePosition.x;
  final blockRight = blockLeft + blockHitbox.size.x;
  final blockTop = blockHitbox.absolutePosition.y;
  final blockBottom = blockTop + blockHitbox.size.y;

  if (adjustedPlayerRight > blockLeft && adjustedPlayerLeft < blockRight) {
    if (playerBottom > blockTop && playerTop < blockBottom) {
      if (player.scale.x < 0) {
        // Player is facing left
        player.position.x = blockRight + (playerHitbox.offsetX * 2) + 4;
      } else {
        // Player is facing right
        player.position.x = blockLeft - (playerHitbox.offsetX * 2) - 4;
      }
    }
  }
}