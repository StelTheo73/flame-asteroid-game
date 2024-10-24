import 'dart:math' show pow, sqrt;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../game.dart';
import '../utils.dart';

class JoystickPlayer extends SpriteComponent with HasGameRef<AsteroidGame> {
  JoystickPlayer(this.joystick)
      : super(
          size: Vector2.all(50.0),
        ) {
    anchor = Anchor.center;
  }

  /// Pixels/s
  double maxSpeed = 300.0;

  final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('asteroids_ship.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
    position = Utils.wrapPosition(gameRef.size, position);
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

  void shake() {
    // shake effect has to be re-declared every time we want to use it,
    // because it's a one-time effect.
    // Otherwise, it will apply the effect only once.
    final MoveEffect shakeEffect = MoveEffect.by(
      Vector2(0, 5),
      ZigzagEffectController(period: 0.2),
    );
    add(shakeEffect);
  }
}
