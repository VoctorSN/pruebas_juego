import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/content/enemies/chicken.dart';
import 'package:fruit_collector/components/game/content/enemies/rockhead.dart';
import 'package:fruit_collector/components/game/content/blocks/loot_box.dart';
import 'package:fruit_collector/components/game/content/levelBasics/checkpoint.dart';
import 'package:fruit_collector/components/game/content/levelBasics/death_zone.dart';
import 'package:fruit_collector/components/game/content/levelBasics/fruit.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/components/game/content/levelExtras/game_text.dart';
import 'package:fruit_collector/components/game/content/traps/saw.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../content/traps/spike.dart';
import 'background_tile.dart';
import '../content/blocks/alterning_block.dart';
import '../content/blocks/collision_block.dart';
import '../content/blocks/falling_block.dart';
import '../content/blocks/trampoline.dart';

class Level extends World with HasGameReference<PixelAdventure> {
  final Player player;
  final String levelName;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _addCollisions();
    _spawningObjects();
    _addGameText();

    return super.onLoad();
  }

  void _addGameText() {
    final textObjects = level.tileMap
        .getLayer<ObjectGroup>('SpawnPoints')
        ?.objects
        .where((obj) => obj.type == 'GameText');

    if (textObjects != null) {
      for (final textObject in textObjects) {
        final text = textObject.text?.text.toString() ?? '';
        final position = Vector2(
          textObject.x + textObject.width / 2,
          textObject.y + textObject.height / 2,
        );

        final gameText = GameText(
          text: text,
          position: Vector2(position.x - textObject.width / 2, position.y),
          maxWidth: textObject.width,
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'ArcadeClassic',
        );

        add(gameText);
      }
    }
  }

  void respawnObjects() {
    for(var component in children) {
      if (component is Trampoline) {
        removeCollisionBlock(component.collisionBlock);
      }
      else if (component is LootBox) {
        removeCollisionBlock(component.collisionBlock);
      }
    }
    removeWhere(
      (component) =>
          component is Fruit ||
          component is Saw ||
          component is Checkpoint ||
          component is Chicken ||
          component is Trampoline ||
          component is DeathZone ||
          component is AlternatingBlock ||
          component is LootBox ||
          component is Rockhead ||
          component is Spike,
    );

    for (CollisionBlock block in collisionBlocks) {
      if (block.parent != null) {
        remove(block);
      }
    }
    collisionBlocks.clear();
    _spawningObjects();
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
              collisionBlocks: collisionBlocks,
            );
            add(chicken);
            break;
          case 'Trampoline':
            final trampoline = Trampoline(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              addCollisionBlock: addCollisionBlock,
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
          case 'rockHead':
            final rockHead = Rockhead(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isReversed: spawnPoint.properties.getValue('isReversed'),
            );
            add(rockHead);
            break;
          case 'Spike':
            final spike = Spike(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              wallPosition: spawnPoint.properties.getValue('position'),
            );
            add(spike);
            break;
          case 'lootBox':
            final lootBox = LootBox(
              position: Vector2(spawnPoint.x - 20, spawnPoint.y - 36),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              addCollisionBlock: addCollisionBlock,
              removeCollisionBlock: removeCollisionBlock,
              objectInside: spawnPoint.properties.getValue('objectInside'),
              addSpawnPoint: addSpawnPoint,
            );
            add(lootBox);
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
                fallingDuration: collision.properties.getValue(
                  'fallingDurationMillSec',
                ),
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

  void addSpawnPoint(var spawnPoint) {
    add(spawnPoint);
  }

  void addCollisionBlock(CollisionBlock collisionBlock) {
    player.collisionBlocks.add(collisionBlock);
    collisionBlocks.add(collisionBlock);
    add(collisionBlock);
  }

  void removeCollisionBlock(CollisionBlock collisionBlock) {
    player.collisionBlocks.remove(collisionBlock);
    collisionBlocks.remove(collisionBlock);
    collisionBlock.removeFromParent();
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