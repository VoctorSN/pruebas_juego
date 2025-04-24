import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:fruit_collector/components/game/spawnpoints/enemies/chicken.dart';
import 'package:fruit_collector/components/game/spawnpoints/levelContent/checkpoint.dart';
import 'package:fruit_collector/components/game/spawnpoints/levelContent/death_zone.dart';
import 'package:fruit_collector/components/game/spawnpoints/levelContent/fruit.dart';
import 'package:fruit_collector/components/game/spawnpoints/levelContent/player.dart';
import 'package:fruit_collector/components/game/spawnpoints/traps/saw.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import 'background_tile.dart';
import 'blocks/alterning_block.dart';
import 'blocks/collision_block.dart';
import 'blocks/falling_block.dart';
import 'blocks/moving_block.dart';
import 'blocks/trampoline.dart';

class Level extends World with HasGameReference<PixelAdventure> {
  final Player player;
  final String levelName;

  Level({required this.levelName, required this.player,});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _addCollisions();
    _spawningObjects();

    return super.onLoad();
  }

  void respawnObjects() {
    removeWhere(
      (component) => component is Fruit || component is Saw || component is Checkpoint || component is Chicken|| component is Trampoline || component is DeathZone
    );
    _spawningObjects();

    collisionBlocks.forEach((block) => remove(block));
    collisionBlocks.clear();
    _addCollisions();
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
              collisionBlocks: collisionBlocks
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
          case 'deathZone':
            final deathZone = DeathZone(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(deathZone);
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
          case 'movingBlock':
            final movingBlock = MovingBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(movingBlock);
            add(movingBlock);
            break;
          case 'alterningBlock':
            final alterningBlock = AlternatingBlock(
              isRed: collision.properties.getValue('isRed'),
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(alterningBlock);
            add(alterningBlock);
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

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue(
        'BackgroundColor',
      );
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }
}