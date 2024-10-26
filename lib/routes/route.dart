import 'package:flame/game.dart';

import '../pages/home.dart';

class GameRouter extends RouterComponent {
  GameRouter({required super.initialRoute, required super.routes});

  final _routes = {
    'home': Route(HomePage.new),
    // 'level': Route(),
    // 'settings': Route(),
    // 'confirm': Route(),
  };
}
