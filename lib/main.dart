import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';

import 'bullet.dart';
import 'joystick_player.dart';

main() {
  final game = AsteroidGame();
  runApp(
    GameWidget(game: game),
  );
}

class AsteroidGame extends FlameGame with DragCallbacks, TapCallbacks {
  static const String description = '''
    In this example we showcase how to use the joystick by creating simple
    `CircleComponent`s that serve as the joystick's knob and background.
    Steer the player by using the joystick. We also show how to shoot bullets
    and how to find the angle of the bullet path relative to the ship's angle
  ''';

  late final JoystickPlayer player;
  late final JoystickComponent joystick;
  final TextPaint shipAngleTextPaint = TextPaint();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //
    // joystick knob and background skin styles
    final knobPaint = BasicPalette.green.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.green.withAlpha(100).paint();
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
    fireBullet(player.angle, player.position, player.getSpeed());
    super.onTapUp(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    shipAngleTextPaint.render(
      canvas,
      '${player.angle.toStringAsFixed(5)} radians',
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
}
