import 'dart:math' show pow, sqrt;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Colors, Paint;

import '../game.dart';
import '../utils/utils.dart';
import 'bullet.new.dart';

class Spaceship extends SpriteComponent
    with HasGameRef<AsteroidGame>, CollisionCallbacks {
  Spaceship(this.joystick)
      : super(
          size: Vector2.all(50.0),
        ) {
    anchor = Anchor.center;
  }

  /// Pixels/s
  double maxSpeed = 300.0;

  final JoystickComponent joystick;
  final BulletEnum _bulletType = BulletEnum.FastBullet;

  // Muzzle component is the point where the bullet will spawn
  RectangleComponent muzzleComponent = RectangleComponent(
    size: Vector2(1, 1),
    paint: Paint()..color = Colors.transparent,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('asteroids_ship.png');
    position = gameRef.size / 2;
    muzzleComponent.position.x = size.x / 2;
    muzzleComponent.position.y = size.y / 10;
    await add(muzzleComponent);
    await add(CircleHitbox());
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
    position = Utils.wrapPosition(gameRef.size, position);
    super.update(dt);
  }

  double getSpeed() {
    if (!joystick.delta.isZero()) {
      final double vx = joystick.relativeDelta.x * maxSpeed;
      final double vy = joystick.relativeDelta.y * maxSpeed;

      return sqrt(pow(vx, 2) + pow(vy, 2));
    } else {
      return 0.0;
    }
  }

  Vector2 getVelocity() {
    return joystick.relativeDelta * maxSpeed;
  }

  BulletEnum getBulletType() {
    return _bulletType;
  }

  Future<void> shake() async {
    // shake effect has to be re-declared every time we want to use it,
    // because it's a one-time effect.
    // Otherwise, it will apply the effect only once.
    final MoveEffect shakeEffect = MoveEffect.by(
      Vector2(0, 5),
      ZigzagEffectController(period: 0.2),
    );
    await add(shakeEffect);
  }

  void reset() {
    position = gameRef.size / 2;
    angle = 0;
  }
}
