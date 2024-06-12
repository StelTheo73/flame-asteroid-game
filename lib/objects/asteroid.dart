import 'dart:math';

import 'package:asteroids_game/game.dart';
import 'package:asteroids_game/objects/lifebar.dart';
import 'package:asteroids_game/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Asteroid extends PositionComponent
    with HasGameRef<AsteroidGame>, TapCallbacks {
  /// Vertices for the asteroid
  final List<Vector2> vertices = [
    Vector2(0.2, 0.8) * 50,
    Vector2(-0.6, 0.6) * 50,
    Vector2(-0.8, 0.2) * 50,
    Vector2(-0.6, -0.4) * 50,
    Vector2(-0.4, -0.8) * 50,
    Vector2(0.0, -1.0) * 50,
    Vector2(0.4, -0.6) * 50,
    Vector2(0.8, -0.8) * 50,
    Vector2(1.0, 0.0) * 50,
    Vector2(0.4, 0.2) * 50,
    Vector2(0.7, 0.6) * 50,
  ];

  late final PolygonComponent asteroid;

  final Vector2 velocity = Vector2(0, 25);
  final double rotationSpeed = 0.3;
  late final LifeBar lifeBar;
  Paint paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  void createLifeBar() {
    lifeBar = LifeBar.initData(
      size,
      size: Vector2(size.x - 10, 5),
      placement: LifeBarPlacement.center,
    );

    add(lifeBar);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    asteroid.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // speed is refresh frequency independent
    position += velocity * dt;
    // add rotational speed update as well
    var angleDelta = dt * rotationSpeed;
    angle = (angle - angleDelta) % (2 * pi);

    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      gameRef.remove(this);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    asteroid = PolygonComponent(
      vertices,
      position: position,
      paint: paint,
      size: Vector2(100, 100),
      anchor: Anchor.center,
    );
    createLifeBar();
  }

  @override
  void onTapUp(TapUpEvent event) {
    lifeBar.decrementCurrentLifeBy(5);

    if (lifeBar.currentLife <= 0) {
      gameRef.remove(this);
    }
  }
}
