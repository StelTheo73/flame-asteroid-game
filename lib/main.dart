import 'package:asteroids_game/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

main() {
  final game = AsteroidGame();
  runApp(
    GameWidget(game: game),
  );
}
