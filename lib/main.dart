import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/pixel_adventure.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();


  PixelAdventure game = PixelAdventure();
  runApp(
      GameWidget(
        game:kDebugMode
            ? PixelAdventure()
            : game,

  ));
}