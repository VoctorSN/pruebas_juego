import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter_flame/actors/player.dart';
import 'dart:async';

import 'package:flutter_flame/levels/level.dart';


class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents{
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');

  @override
  FutureOr<void> onLoad() async{

    // Carga todas las imagenes al caché
    await images.loadAllImages();

  final world = Level(levelName: 'Level-01',player: player);

    cam = CameraComponent.withFixedResolution(world: world,width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam,world,]);

    return super.onLoad();
  }
}