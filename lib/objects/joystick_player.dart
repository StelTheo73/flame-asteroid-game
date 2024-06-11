import 'dart:math' show pow, sqrt;
import 'package:flame/components.dart';

class JoystickPlayer extends SpriteComponent with HasGameRef {
  /// Pixels/s
  double maxSpeed = 300.0;

  final JoystickComponent joystick;

  JoystickPlayer(this.joystick)
      : super(
          size: Vector2.all(50.0),
        ) {
    anchor = Anchor.center;
  }

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
      angle = (joystick.delta.screenAngle());
    }
  }

  double getSpeed() {
    if (!joystick.delta.isZero()) {
      double vx = joystick.relativeDelta.x * maxSpeed;
      double vy = joystick.relativeDelta.y * maxSpeed;

      return sqrt(pow(vx, 2) + pow(vy, 2));
    } else {
      return 0.0;
    }
  }
}
