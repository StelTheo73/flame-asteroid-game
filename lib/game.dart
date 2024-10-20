import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'objects/asteroid.dart';
import 'objects/bullet.dart';
import 'objects/joystick_player.dart';

class AsteroidGame extends FlameGame<World> with DragCallbacks, TapCallbacks {
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

  final TimerComponent timer = TimerComponent(
    period: 10,
    repeat: true,
    onTick: () {
      print('10 seconds elapsed');
    },
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await setup();

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
    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!running) {
      return;
    }
    // handleAsteroidTap(event);
    fireBullet(player.angle, player.position, player.getSpeed());
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
    add(Bullet(
      position: initialPosition,
      angle: angle,
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

  Future<void> setup() async {
    // Parallax background
    await setupParallax();

    addOverlays();
    addTimers();
  }

  Future<void> togglePause() async {
    running ? await pause() : await resume();
    running = !running;
  }

  Future<void> pause() async {
    super.pauseEngine();
    await FlameAudio.bgm.pause();
  }

  Future<void> resume() async {
    super.resumeEngine();
    await FlameAudio.bgm.resume();
  }

  TimerComponent createCountdownTimer() {
    late final TimerComponent countdown;
    countdown = TimerComponent(
      removeOnFinish: true,
      period: 5,
      onTick: () {
        print('Countdown timer tick');
        if (countdown.timer.finished) {
          print('Countdown timer finished');
        }
      },
    );
    return countdown;
  }

  void addTimers() {
    // Interval timer (runs every 10 seconds)
    add(timer);
    // Countdown timer
    final TimerComponent countdown = createCountdownTimer();
    countdown.timer.start();
    add(countdown);
  }

  void addOverlays() {
    overlays.add('PauseButton');
  }

  Future<void> setupParallax() async {
    final List<ParallaxImageData> images = <ParallaxImageData>[
      ParallaxImageData('parallax/big_stars.png'),
      ParallaxImageData('parallax/small_stars.png'),
    ];
    final ParallaxComponent<FlameGame<World>> parallax =
        await loadParallaxComponent(
      images,
      baseVelocity: Vector2(0.0, -25.0),
      velocityMultiplierDelta: Vector2(1.0, 1.8),
      repeat: ImageRepeat.repeat,
    );
    add(parallax);
  }
}
