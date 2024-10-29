import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import 'bullet.dart';
import 'joystick_player.dart';
import 'lifebar_text.dart';
import 'particle.dart';

class Ball extends CircleComponent
    with HasGameRef<AsteroidGame>, CollisionCallbacks {
  /// Default constructor with hardcoded radius and a hitbox definition
  Ball(Vector2 position, Vector2 velocity, double speed, int ordinalNumber)
      : super(position: position, radius: 20, anchor: Anchor.center) {
    xDirection = velocity.x.toInt();
    yDirection = velocity.y.toInt();
    _speed = speed;
    add(CircleHitbox());
    _healthText = LifeBarText(ordinalNumber)
      ..x = 0
      ..y = -size.y / 2;
  }
  final Color _currentColor = Colors.cyan;
  late double _speed;
  late LifeBarText _healthText;

  /// direction vector split into constituent x and y elements
  /// we start with the vector (1, 1) which is pointing down
  /// but do note that since we are randomly generating the direction
  /// in this exercise the initial values are irrelevant.
  int xDirection = 1;
  int yDirection = 1;

  /// The life value of the ball.
  /// Starts with this number (10) and then is depleted at each collision by 1
  int _objectLifeValue = 100;

  /// The map of ids of the objects we have recently collided with
  ///
  Map<String, Ball> collisions = <String, Ball>{};

  @override
  Future<void> onLoad() async {
    add(_healthText);
    await super.onLoad();
  }

  @override
  void update(double dt) {
    /// check for any unresolved collisions
    ///
    final List<String> keys = <String>[];
    for (final MapEntry<String, Ball> other in collisions.entries) {
      final Ball otherObject = other.value;
      if (distance(otherObject) > size.x) {
        keys.add(other.key);
      }
    }
    collisions.removeWhere((key, value) => keys.contains(key));

    x += xDirection * _speed * dt;
    y += yDirection * _speed * dt;

    /// get the bounding rectangle for our 'ball' object
    final Rect rect = toRect();

    /// check for collision between the ball and the screen boundaries
    /// by testing each  component of the direction vector's x and y
    ///
    ///

    /// check if we passed the left or right screen edge
    ///

    /// left/right edge wrap
    if (rect.left <= -rect.width && xDirection == -1) {
      x = gameRef.size.x;
    } else if (rect.right >= gameRef.size.x + rect.width && xDirection == 1) {
      x = 0;
    }

    /// check if we passed the top or bottom screen edge
    ///

    /// top/bottom edge wrap
    if (rect.top <= -rect.height && yDirection == -1) {
      y = gameRef.size.y;
    } else if (rect.bottom >= gameRef.size.y + rect.height && yDirection == 1) {
      y = 0;
    }
    _healthText.healthData = _objectLifeValue;

    /// remove this objects if its life has ended.

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // rs(canvas);
    paint = Paint()..color = _currentColor;
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet) {
      await gameRef.add(ParticleGenerator.createParticleExplosion(
        position: other.position,
      ));
      await FlameAudio.play('missile_hit.wav', volume: 0.7);
      _objectLifeValue = _objectLifeValue - 10;
      try {
        gameRef.remove(other);
      } catch (e) {}
      // update the score
      gameRef.score++;
    }
    if (other is JoystickPlayer) {
      await gameRef.add(ParticleGenerator.createSpriteParticleExplosion(
        images: gameRef.images,
        position: other.position,
      ));
      await FlameAudio.play('missile_hit.wav', volume: 0.7);
      await gameRef.player.shake();
      if (gameRef.isPlayerAlive()) {
        gameRef.remove(other);
      }
    }

    if (_objectLifeValue <= 0 || other is JoystickPlayer) {
      try {
        gameRef.remove(this);
      } catch (e) {
        print('Error removing object: $e');
      }
    }
  }
}
