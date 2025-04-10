import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_flame/components/checkpoint.dart';
import 'package:flutter_flame/components/chicken.dart';
import 'package:flutter_flame/components/collision_block.dart';
import 'package:flutter_flame/components/fallingBlock.dart';
import 'package:flutter_flame/components/fruit.dart';
import 'package:flutter_flame/components/player.dart';
import 'package:flutter_flame/components/saw.dart';
import 'package:flutter_flame/pixel_adventure.dart';

import 'trampoline.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final Player player;
  final String levelName;

  Level({required this.levelName, required this.player,});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _addParallaxBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  Future<void> _addParallaxBackground() async {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');
      final color = backgroundColor ?? 'Gray';
      final parallax = await game.loadParallax(
        [
          ParallaxImageData('Background/$color.png'),
          // o el color que necesites
        ],
        baseVelocity: Vector2(0, -40), // scroll vertical
        repeat: ImageRepeat.repeat,
        fill: LayerFill.none,
      );

      add(ParallaxComponent(parallax: parallax)..priority = -1);
    }
  }

  void respawnObjects() {
    removeWhere(
      (component) => component is Fruit || component is Saw || component is Checkpoint || component is Chicken|| component is Trampoline,
    );
    _spawningObjects();
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.statringPosition = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final saw = Saw(
              offNeg: offNeg,
              offPos: offPos,
              isVertical: isVertical,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
            );
            add(chicken);
            break;
          case 'Trampoline':
            final trampoline = Trampoline(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              powerBounce: spawnPoint.properties.getValue('powerBounce'),
            );
            add(trampoline);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            if (collision.properties.getValue('falls')) {
              final fallingPlatform = FallingBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true,
                fallingDuration: collision.properties.getValue('fallingDurationMillSec'),
              );
              collisionBlocks.add(fallingPlatform);
              add(fallingPlatform);
              break;
            }
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          case 'Sand':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isSand: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  bool checkpointEnabled() {
    return !_hasFruits();
  }

  bool _hasFruits() {
    return children.any((component) => component is Fruit);
  }
}