import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';

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
enum AsteroidEnum { largeAsteroid, mediumAsteroid, smallAsteroid }

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
  //
  // default constructor with default values
  Asteroid(Vector2 position, Vector2 velocity, Vector2 size)
      : _velocity = velocity.normalized(),
        _speed = defaultSpeed,
        _health = defaultHealth,
        _damage = defaultDamage,
        super(
          size: size,
          position: position,
          anchor: Anchor.center,
        );
  //
  // named constructor
  Asteroid.fullInit(Vector2 position, Vector2 velocity, Vector2 size,
      {double? speed, int? health, int? damage})
      : _velocity = velocity.normalized(),
        _speed = speed ?? defaultSpeed,
        _health = health ?? defaultHealth,
        _damage = damage ?? defaultDamage,
        super(
          size: size,
          position: position,
          anchor: Anchor.center,
        );
  static const double defaultSpeed = 100.00;
  static const int defaultDamage = 1;
  static const int defaultHealth = 1;

  // velocity vector for the asteroid.
  late Vector2 _velocity;

  // speed of the asteroid
  late final double _speed;

  // health of the asteroid
  late int? _health;

  // damage that the asteroid does
  late int? _damage;

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
  void onCreate();

  //
  // Called when the asteroid is being destroyed.
  void onDestroy();

  //
  // Called when the asteroid has been hit. The ‘other’ is what the asteroid
  // hit, or was hit by.
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other);

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
    return List<AsteroidEnum>.empty();
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
  SmallAsteroid(super.position, super.velocity, super.size)
      : super.fullInit(
            speed: defaultSpeed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage) {
    add(CircleHitbox());
  }
  //
  // named constructor
  SmallAsteroid.fullInit(Vector2 position, Vector2 velocity, Vector2 size,
      double? speed, int? health, int? damage)
      : super.fullInit(position, velocity, size,
            speed: speed, health: health, damage: damage) {
    add(CircleHitbox());
  }
  static const double defaultSpeed = 150.0;
  // color of the asteroid
  static final Paint _paint = Paint()..color = Colors.green;

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

/// This is a Factory Method Design pattern example implementation for Asteroids
/// in our game.
///
/// The class will return an instance of the specific asteroid aksed for based
/// on a valid asteroid type choice.
class AsteroidFactory {
  /// private constructor to prevent instantiation
  AsteroidFactory._();

  /// main factory method to create instaces of Bullet children
  static Asteroid? create(AsteroidBuildContext context) {
    Asteroid? result;

    /// collect all the Asteroid definitions here
    // switch (context.asteroidType) {
    //   // <TODO> creation logic
    // }

    return result;
  }
}

/// This is a simple data holder for the context data wehen we create a new
/// Asteroid instace through the Factory method using the [AsteroidFactory]
///
/// We have a number of default values here as well in case callers do not
/// define all the entries.
class AsteroidBuildContext {
  AsteroidBuildContext();
  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 deaultVelocity = Vector2.zero();
  static final Vector2 deaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final AsteroidEnum defaultAsteroidType = AsteroidEnum.values[0];
  static final Vector2 defaultMultiplier = Vector2.all(1.0);

  /// helper method for parsing out strings into corresponding enum values
  ///
  static AsteroidEnum asteroidFromString(String value) {
    print('${AsteroidEnum.values}');
    return AsteroidEnum.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }

  double speed = defaultSpeed;
  Vector2 velocity = deaultVelocity;
  Vector2 position = deaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
  Vector2 multiplier = defaultMultiplier;
  AsteroidEnum asteroidType = defaultAsteroidType;

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'name: $asteroidType , speed: $speed , position: $position , velocity: $velocity, multiplier: $multiplier';
  }
}
