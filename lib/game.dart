import 'package:asteroids_game/objects/asteroid.dart';
import 'package:asteroids_game/objects/bullet.dart';
import 'package:asteroids_game/objects/joystick_player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AsteroidGame extends FlameGame with DragCallbacks, TapCallbacks {
  @override
  bool debugMode = false;

  bool running = true;

  late final JoystickPlayer player;
  late final JoystickComponent joystick;
  final TextPaint shipAngleTextPaint = TextPaint();

  final Paint paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //
    // joystick knob and background skin styles
    final Paint knobPaint = BasicPalette.green.withAlpha(200).paint();
    final Paint backgroundPaint = BasicPalette.green.withAlpha(100).paint();
    //
    // Actual Joystick component creation
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 15, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 20, bottom: 20),
    );

    player = JoystickPlayer(joystick);

    add(player);
    add(joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    handleAsteroidTap(event);
    // fireBullet(player.angle, player.position, player.getSpeed());
    super.onTapUp(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    shipAngleTextPaint.render(
      canvas,
      'Objects active: ${children.length}',
      Vector2(20, size.y - 24),
    );
  }

  void fireBullet(double angle, Vector2 initialPosition, double initialSpeed) {
    final Vector2 velocity = Vector2(0, -1);
    velocity.rotate(angle);
    add(Bullet(
      position: initialPosition,
      velocity: velocity,
      initialSpeed: initialSpeed,
    ));
  }

  void handleAsteroidTap(TapUpEvent event) {
    // location of user's tap
    final Vector2 touchPoint = event.localPosition;

    final bool handled = children.any((component) {
      if (component is Asteroid && component.containsPoint(touchPoint)) {
        component.velocity.negate();
        return true;
      }
      return false;
    });

    //
    // this is a clean location with no shapes
    // create and add a new shape to the component tree under the FlameGame
    if (!handled) {
      add(Asteroid()
        ..position = touchPoint
        ..size = Vector2.all(50)
        ..anchor = Anchor.center
        ..paint = paint);
    }
  }

  // @override
  // void onDoubleTapUp(DoubleTapEvent event) {
  //   running ? pauseEngine() : resumeEngine();
  //   running = !running;
  // }
}
