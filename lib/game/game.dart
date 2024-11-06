import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

import '../objects/asteroid.dart';
import '../objects/ball.dart';
import '../objects/spaceship.dart';
import '../utils/command.dart';
import '../utils/config.dart';
import '../utils/controller.dart';
import '../utils/utils.dart';

class AsteroidGame extends FlameGame<World>
    with DragCallbacks, TapCallbacks, HasCollisionDetection {
  AsteroidGame({required this.levelId});

  bool running = true;
  int levelId;

  late final Spaceship player;
  late final JoystickComponent joystick;
  late final ParallaxComponent<FlameGame<World>> parallax;
  final Controller controller = Controller();
  final Vector2 parallaxBaseVelocity = Vector2(0, -25);
  final TextPaint shipAngleTextPaint = TextPaint();

  List<Asteroid> asteroids = <Asteroid>[];

  // Number of balls and number of timer ticks
  static const int numSimulationObjects = 4;
  // Number of extra lives the player will have in the game
  static const int numPlayerLivesExtra = 3;
  int playerLivesLeft = numPlayerLivesExtra;
  // Bullets shot
  int numberOfBulletsShot = 0;
  // Score
  int score = 0;
  // Elapsed timer ticks
  int elapsedTicks = 0;

  final Paint paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final TextPaint textDashboard = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 15),
  );

  // Timers
  late final TimerComponent intervalTimer;
  late final TimerComponent spawnTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await setup();
    await loadLevel();

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

    player = Spaceship(joystick);

    await add(controller);
    await add(player);
    await add(joystick);

    await controller.init();
  }

  @override
  void update(double dt) {
    if (!isPlayerAlive()) {
      parallax.parallax?.baseVelocity = Vector2.zero();
      super.update(dt);
      return;
    }
    final Vector2 velocity = parallaxBaseVelocity.clone();
    final Vector2 playerVelocity = player.getVelocity();
    velocity.rotate(player.angle);
    parallax.parallax?.baseVelocity = playerVelocity + velocity;

    try {
      super.update(dt);
    } catch (e) {
      print('====== ERROR ======');
      print('===================');
      print('Error updating game: $e');
    }
  }

  @override
  Future<void> onTapUp(TapUpEvent event) async {
    if (!running || !isPlayerAlive()) {
      return;
    }
    UserTapUpCommand(player).addToController(controller);
    super.onTapUp(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (playerLivesLeft >= 0) {
      // Extra lives
      textDashboard.render(
        canvas,
        'Extra lives: $playerLivesLeft',
        Vector2(20, 20),
      );
    } else {
      // Game over
      textDashboard.render(
        canvas,
        'Game Over',
        Vector2(20, 20),
      );
    }

    // Bullets shot
    textDashboard.render(
      canvas,
      'Bullets shot: $numberOfBulletsShot',
      Vector2(20, 60),
    );

    // Score
    textDashboard.render(
      canvas,
      'Score: $score',
      Vector2(20, 40),
    );

    // Active objects
    shipAngleTextPaint.render(
      canvas,
      'Objects active: ${children.length}',
      Vector2(20, size.y - 24),
    );
  }

  Future<void> setup() async {
    await cacheImages();
    await setupParallax();
    addOverlays();
    // do not load balls
    // await addTimers();
  }

  Future<void> loadLevel() async {
    final YamlMap levelData = await Configuration.getLevelData(levelId);
    print('Setting up level: $levelId');
    print('level data: ${levelData}');

    // clear just in case
    asteroids.clear();

    for (final dynamic asteroidData in levelData['asteroids'] as Iterable) {
      final AsteroidBuildContext context = AsteroidBuildContext()
        ..speed = asteroidData['speed'] as double
        ..position = Vector2(
          (asteroidData['position.x'] as int).toDouble(),
          (asteroidData['position.y'] as int).toDouble(),
        )
        ..asteroidType =
            AsteroidEnum.fromString(asteroidData['name'] as String);
      final Asteroid? newAsteroid = AsteroidFactory.create(context);

      if (newAsteroid != null) {
        await add(newAsteroid);
        asteroids.add(newAsteroid);
      }
    }
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

  Future<void> addTimers() async {
    // Interval timer (runs every 4 seconds)
    intervalTimer = TimerComponent(
      period: 4.00,
      removeOnFinish: true,
      onTick: () async {
        final Vector2 rndPosition =
            Utils.generateRandomPosition(size, Vector2.all(50));
        final Vector2 rndVelocity = Utils.generateRandomDirection();
        final double rndSpeed = Utils.generateRandomSpeed(20, 100);

        final Ball ball =
            Ball(rndPosition, rndVelocity, rndSpeed, elapsedTicks);

        await add(ball);

        elapsedTicks++;

        if (elapsedTicks > numSimulationObjects) {
          intervalTimer.timer.stop();
          remove(intervalTimer);
        }
      },
      repeat: true,
    );

    // Spawn timer
    spawnTimer = TimerComponent(
      period: 4.00,
      removeOnFinish: true,
      onTick: () async {
        if (!isPlayerAlive()) {
          playerLivesLeft--;
          if (playerLivesLeft >= 0) {
            player.reset();
            await add(player);
            return;
          }
          remove(spawnTimer);
        }
      },
      repeat: true,
    );

    // Countdown timer
    final TimerComponent countdownTimer = createCountdownTimer();
    countdownTimer.timer.start();

    await add(countdownTimer);
    await add(intervalTimer);
    await add(spawnTimer);
  }

  void addOverlays() {
    overlays.add('PauseButton');
  }

  Future<void> setupParallax() async {
    final Map<String, double> layersMeta = <String, double>{
      'parallax/big_stars.png': 1.0,
      'parallax/small_stars.png': 1.5,
    };

    final Iterable<Future<ParallaxLayer>> layers = layersMeta.entries.map(
      (MapEntry<String, double> layer) => loadParallaxLayer(
        ParallaxImageData(layer.key),
        velocityMultiplier: Vector2(1.0, layer.value),
        repeat: ImageRepeat.repeat,
      ),
    );

    parallax = ParallaxComponent<FlameGame<World>>(
      parallax: Parallax(
        await Future.wait(layers),
        baseVelocity: parallaxBaseVelocity,
      ),
    );

    await add(parallax);
  }

  Future<void> cacheImages() async {
    await images.load('parallax/big_stars.png');
    await images.load('parallax/small_stars.png');
    await images.load('boom.png');
    await images.load('asteroids_ship.png');
  }

  bool isPlayerAlive() {
    if (children.any((Component element) => element is Spaceship)) {
      return true;
    }
    return false;
  }
}
