import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game.dart';

enum BulletEnum { SlowBullet, FastBullet }

/// Bullet class is a [PositionComponent] so we get the angle and position of the
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
abstract class Bullet extends PositionComponent
    with HasGameRef<AsteroidGame>, CollisionCallbacks {
  //
  // default constructor with default values
  Bullet(Vector2 position, Vector2 velocity, Vector2 size)
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
  // empty class name constructor
  Bullet.classname();

  //
  // named constructor
  Bullet.fullInit(Vector2 position, Vector2 velocity, Vector2 size,
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

  // velocity vector for the bullet.
  late Vector2 _velocity;

  // speed of the bullet
  late double _speed;

  // health of the bullet
  late int? _health;

  // damage that the bullet does
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
  // Called when the Bullet has been created.
  void onCreate();

  //
  // Called when the bullet is being destroyed.
  void onDestroy();

  //
  // Called when the Bullet has been hit. The ‘other’ is what the bullet hit, or was hit by.
  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other);
}

/// This class creates a fast bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple green square.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class FastBullet extends Bullet {
  FastBullet(super.position, super.velocity, super.size)
      : super.fullInit(
            speed: defaultSpeed,
            health: Bullet.defaultHealth,
            damage: Bullet.defaultDamage);

  //
  // named constructor
  FastBullet.fullInit(super.position, super.velocity, super.size, double? speed,
      int? health, int? damage)
      : super.fullInit(speed: speed, health: health, damage: damage);

  // color of the bullet
  static final Paint _paint = Paint()..color = Colors.green;
  static const double defaultSpeed = 300.00;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    print('FastBullet onLoad called: speed: $_speed');
    _velocity = _velocity..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
  }

  @override
  void onCreate() {
    print('FastBullet onCreate called');
  }

  @override
  void onDestroy() {
    print('FastBullet onDestroy called');
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    print('FastBullet onHit called');

    super.onCollision(intersectionPoints, other);
  }
}

/// This class creates a slow bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple red filled-in circle.
/// Speed has been defaulted to 50 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class SlowBullet extends Bullet {
  SlowBullet(super.position, super.velocity, super.size)
      : super.fullInit(
            speed: defaultSpeed,
            health: Bullet.defaultHealth,
            damage: Bullet.defaultDamage);

  //
  // named constructor
  SlowBullet.fullInit(super.position, super.velocity, super.size, double? speed,
      int? health, int? damage)
      : super.fullInit(speed: speed, health: health, damage: damage);

  // color of the bullet
  static final Paint _paint = Paint()..color = Colors.red;
  static const double defaultSpeed = 50.00;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    _velocity = _velocity..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
    //canvas.drawCircle(size.toRect(), _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
  }

  @override
  void onCreate() {
    print('SlowBullet onCreate called');
  }

  @override
  void onDestroy() {
    print('SlowBullet onDestroy called');
  }

  @override
  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    print('SlowBullet onHit called');

    super.onCollision(intersectionPoints, other);
  }
}

/// This is a Factory Method Design pattern example implementation for Bullets
/// in our game.
///
/// The class will return an instance of the specific bullet aksed for based on
/// a valid bullet choice.
class BulletFactory {
  /// private constructor to prevent instantiation
  BulletFactory._();

  /// main factory method to create instances of Bullet children
  static Bullet create(BulletEnum choice, BulletBuildContext context) {
    Bullet result;

    /// collect all the Bullet definitions here
    switch (choice) {
      case BulletEnum.SlowBullet:
        {
          if (context.speed != BulletBuildContext.defaultSpeed) {
            result = SlowBullet.fullInit(context.position, context.velocity,
                context.size, context.speed, context.health, context.damage);
          } else {
            result =
                SlowBullet(context.position, context.velocity, context.size);
          }
        }

      case BulletEnum.FastBullet:
        {
          if (context.speed != BulletBuildContext.defaultSpeed) {
            result = FastBullet.fullInit(context.position, context.velocity,
                context.size, context.speed, context.health, context.damage);
          } else {
            result =
                FastBullet(context.position, context.velocity, context.size);
          }
        }
    }

    ///
    /// trigger any necessary behavior *before* the instance is handed to the
    /// caller.
    result.onCreate();

    return result;
  }
}

/// This is a simple data holder for the context data when we create a new
/// Bullet instace through the Factory method using the [BulletFactory]
///
/// We have a number of default values here as well in case callers do not
/// define all the entries.
class BulletBuildContext {
  BulletBuildContext();

  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 defaultVelocity = Vector2.zero();
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();

  double speed = defaultSpeed;
  Vector2 velocity = defaultVelocity;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
}
