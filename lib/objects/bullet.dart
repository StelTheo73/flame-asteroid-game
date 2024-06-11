import 'package:asteroids_game/game.dart';
import 'package:asteroids_game/utils.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

//
//
// Bullet class is a PositionComponent so we get the angle and position of the
// element.
class Bullet extends PositionComponent with HasGameRef<AsteroidGame> {
  // color of the bullet
  static final _paint = Paint()..color = Colors.white;
  // the bullet speed in pixels per second
  late final double _speed;

  // velocity vector for the bullet.
  late Vector2 _velocity;

  //
  // default constructor with default values
  Bullet(
      {required Vector2 position,
      required Vector2 velocity,
      double initialSpeed = 0})
      : _velocity = velocity,
        _speed = initialSpeed + 150,
        super(
          position: position,
          size: Vector2.all(4), // 2x2 bullet
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    _velocity = (_velocity)..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);

    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      gameRef.remove(this);
    }
  }
}
