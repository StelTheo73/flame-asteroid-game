import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';
import '../utils/command.dart';
import '../utils/utils.dart';
import 'bullet.new.dart';
import 'spaceship.dart';

/// Simple enum which will hold enumerated names for all our [Asteroid]-derived
/// child classes
///
/// As you add moreBullet implementation you will add a name hereso that we
/// can then easily create asteroids using the [AsteroidFactory]
/// The steps are as follows:
///  - extend the astroid class with a new Asteroid implementation
///  - add a new enumeration entry
///  - add a new switch case to the [AsteroidFactory] to create this
///    new [Asteroid] instance when the enumeration entry is provided.
enum AsteroidEnum {
  largeAsteroid,
  mediumAsteroid,
  smallAsteroid;

  static AsteroidEnum fromString(String value) {
    return AsteroidEnum.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }
}

// Bullet class is a [PositionComponent] so we get the angle and position of the
/// element.
///
/// This is an abstract class which needs to be extended to use Bullets.
/// The most important game methods come from [PositionComponent] and are the
/// update(), onLoad(), amd render() methods that need to be overridden to
/// drive the behavior of your Bullet on screen.
///
/// You should also override the abstract methods such as onCreate(),
/// onDestroy(), and onHit()
///
abstract class Asteroid extends PositionComponent
    with HasGameRef<AsteroidGame>, CollisionCallbacks {
  static const double defaultSpeed = 100.00;
  static const int defaultDamage = 1;
  static const int defaultHealth = 1;
  static final defaultSize = Vector2.all(5.0);

  // velocity vector for the asteroid.
  late Vector2 _velocity;

  // speed of the asteroid
  late double _speed;

  // health of the asteroid
  late int? _health;

  // damage that the asteroid does
  late int? _damage;

  // resolution multiplier
  late final Vector2 _resolutionMultiplier;

  //
  // default constructor with default values
  Asteroid(Vector2 position, Vector2 velocity, double speed,
      Vector2 resolutionMultiplier)
      : _velocity = velocity.normalized(),
        _health = defaultHealth,
        _damage = defaultDamage,
        _resolutionMultiplier = resolutionMultiplier,
        super(
          size: defaultSize,
          position: position,
          anchor: Anchor.center,
        );

  //
  // named constructor
  Asteroid.fullInit(
      Vector2 position, Vector2 velocity, Vector2 resolutionMultiplier,
      {Vector2? size, double? speed, int? health, int? damage})
      : _resolutionMultiplier = resolutionMultiplier,
        _velocity = velocity.normalized(),
        _speed = speed ?? defaultSpeed,
        _health = health ?? defaultHealth,
        _damage = damage ?? defaultDamage,
        super(
          size: size,
          position: position,
          anchor: Anchor.center,
        );

  ///////////////////////////////////////////////////////
  /// overrides
  ///

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Bullet) {
      // parent?.remove(other);
      //parent?.remove(this);
      BulletCollisionCommand(other, this).addToController(gameRef.controller);
      AsteroidCollisionCommand(this, other).addToController(gameRef.controller);
      debugPrint("<Asteroid> <onCollision> detected... $other");
    }

    if (other is Spaceship) {
      //parent?.remove(this);
      //parent?.add(ParticleGenerator.createSpriteParticleExplosion(
      //  images: gameRef.images,
      //  position: other.position,
      //));
      FlameAudio.play('missile_hit.wav', volume: 0.7);
      // render the camera shake effect for a short duration
      gameRef.player.shake();
      parent?.parent?.remove(other);
      debugPrint("<Asteroid> <onCollision> detected... $other");
    }
  }

  ///////////////////////////////////////////////////////
  // getters
  //
  int? get getDamage {
    return _damage;
  }

  int? get getHealth {
    return _health;
  }

  ////////////////////////////////////////////////////////
  // business methods
  //

  //
  // Called when the asteroid has been created.
  void onCreate() {
    debugPrint("<Asteroid> <onCreate> multiplier applied");
    // apply the multiplier to the size and position
    size = Utils.vector2Multiply(size, _resolutionMultiplier);
    debugPrint(
        "<Asteroid> <onLoad> size: $size, multiplier: $_resolutionMultiplier");
    size.y = size.x;
    position = Utils.vector2Multiply(position, _resolutionMultiplier);
    debugPrint("<Asteroid> <onCreate> size: ${size.x}, ${size.y}");
    add(CircleHitbox(radius: 2.0));
  }

  //
  // Called when the asteroid is being destroyed.
  void onDestroy();

  //
  // getter to check of this asteroid can be split
  bool canBeSplit() {
    return getSplitAsteroids().isNotEmpty;
  }

  // should return the list of the astroid types to split this asteroid into
  // or empty list if there is none (i.e. no split)
  // You will override this method to return a non-empty list if valid enum
  // values for when the astroid gets split when it is hit
  List<AsteroidEnum> getSplitAsteroids() {
    return List.empty();
  }

  Vector2 getNextPosition() {
    return Utils.wrapPosition(gameRef.size, position);
  }
}

/// This class creates a fast bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple green square.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class SmallAsteroid extends Asteroid {
  SmallAsteroid(
      double speed, super.position, super.velocity, super.resolutionMultiplier)
      : super.fullInit(
            speed: speed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage,
            size: defaultSize);

  //
  // named constructor
  SmallAsteroid.fullInit(
      Vector2 position,
      Vector2 velocity,
      Vector2 resolutionMultiplier,
      Vector2? size,
      double? speed,
      int? health,
      int? damage)
      : super.fullInit(position, velocity, resolutionMultiplier,
            size: size, speed: speed, health: health, damage: damage);

  static const double defaultSpeed = 150.0;
  static final Vector2 defaultSize = Vector2(16.0, 16.0);
  // color of the asteroid
  static final _paint = Paint()..color = Colors.green;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    print("SmallAsteroid onLoad called: speed: $_speed");
    _velocity = _velocity..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final localCenter = (scaledSize / 2).toOffset();
    canvas.drawCircle(localCenter, 8, _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
  }

  @override
  void onCreate() {
    print("SmallAsteroid onCreate called");
  }

  @override
  void onDestroy() {
    print("SmallAsteroid onDestroy called");
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    print("SmallAsteroid onCollision called");
    super.onCollision(intersectionPoints, other);
  }
}

/// This class creates a fast bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple green square.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class MediumAsteroid extends Asteroid {
  MediumAsteroid(
      double speed, super.position, super.velocity, super.resolutionMultiplier)
      : super.fullInit(
            speed: speed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage,
            size: defaultSize);
  //
  // named constructor
  MediumAsteroid.fullInit(
      Vector2 position,
      Vector2 velocity,
      Vector2 resolutionMultiplier,
      Vector2? size,
      double? speed,
      int? health,
      int? damage)
      : super.fullInit(position, velocity, resolutionMultiplier,
            size: size, speed: speed, health: health, damage: damage);

  static const double defaultSpeed = 100.0;
  static final Vector2 defaultSize = Vector2(32.0, 32.0);
  // color of the asteroid
  static final _paint = Paint()..color = Colors.blue;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    print("MediumAsteroid onLoad called: speed: $_speed");
    _velocity = _velocity..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final localCenter = (scaledSize / 2).toOffset();
    canvas.drawCircle(localCenter, 8, _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
  }

  @override
  void onCreate() {
    print("MediumAsteroid onCreate called");
  }

  @override
  void onDestroy() {
    print("MediumAsteroid onDestroy called");
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    print("MediumAsteroid onCollision called");
    super.onCollision(intersectionPoints, other);
  }
}

/// This class creates a fast bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple green square.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class LargeAsteroid extends Asteroid {
  LargeAsteroid(
      double speed, super.position, super.velocity, super.resolutionMultiplier)
      : super.fullInit(
            speed: speed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage,
            size: defaultSize);

  //
  // named constructor
  LargeAsteroid.fullInit(
      super.position,
      super.velocity,
      super.resolutionMultiplier,
      Vector2? size,
      double? speed,
      int? health,
      int? damage)
      : super.fullInit(
            size: size, speed: speed, health: health, damage: damage);

  static const double defaultSpeed = 65.0;
  static final Vector2 defaultSize = Vector2(64.0, 64.0);
  // color of the asteroid
  static final Paint _paint = Paint()..color = Colors.red;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    print("LargeAsteroid onLoad called: speed: $_speed");
    _velocity = _velocity..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final localCenter = (scaledSize / 2).toOffset();
    canvas.drawCircle(localCenter, 8, _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
  }

  @override
  void onCreate() {
    print("LargeAsteroid onCreate called");
  }

  @override
  void onDestroy() {
    print("LargeAsteroid onDestroy called");
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    print("LargeAsteroid onCollision called");
    super.onCollision(intersectionPoints, other);
  }
}

/// This is a Factory Method Design pattern example implementation for Asteroids
/// in our game.
///
/// The class will return an instance of the specific asteroid asked for based
/// on a valid asteroid type choice.
class AsteroidFactory {
  /// private constructor to prevent instantiation
  AsteroidFactory._();

  /// main factory method to create instances of Bullet children
  static Asteroid? create(AsteroidBuildContext context) {
    Asteroid? result;

    /// collect all the Asteroid definitions here
    // switch (context.asteroidType) {
    //   // <TODO> creation logic
    // }

    switch (context.asteroidType) {
      case AsteroidEnum.largeAsteroid:
        {
          result = LargeAsteroid(
            context.speed,
            context.position,
            context.velocity,
            context.multiplier,
          );
          break;
        }
      case AsteroidEnum.mediumAsteroid:
        {
          result = MediumAsteroid(
            context.speed,
            context.position,
            context.velocity,
            context.multiplier,
          );
        }
      case AsteroidEnum.smallAsteroid:
        {
          result = SmallAsteroid(
            context.speed,
            context.position,
            context.velocity,
            context.multiplier,
          );
        }
    }
    return result;
  }
}

/// This is a simple data holder for the context data when we create a new
/// Asteroid instance through the Factory method using the [AsteroidFactory]
///
/// We have a number of default values here as well in case callers do not
/// define all the entries.
class AsteroidBuildContext {
  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 defaultVelocity = Vector2.zero();
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final AsteroidEnum defaultAsteroidType = AsteroidEnum.values[0];
  static final Vector2 defaultMultiplier = Vector2.all(1.0);

  /// helper method for parsing out strings into corresponding enum values
  ///
  static AsteroidEnum asteroidFromString(String value) {
    debugPrint('${AsteroidEnum.values}');
    return AsteroidEnum.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }

  double speed = defaultSpeed;
  Vector2 velocity = defaultVelocity;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
  Vector2 multiplier = defaultMultiplier;
  AsteroidEnum asteroidType = defaultAsteroidType;

  AsteroidBuildContext();

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'name: $asteroidType , speed: $speed , position: $position , velocity: $velocity, multiplier: $multiplier';
  }
}
