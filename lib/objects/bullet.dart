import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import '../utils/utils.dart';

// FlameAudio.audioCache.loadAll([
//   'laser_004.wav',
// ]);

class Bullet extends PositionComponent with HasGameRef<AsteroidGame> {
  static final _paint = Paint()..color = Colors.white;
  // the bullet speed in pixels per second
  late final double _speed;

  // velocity vector for the bullet.
  late Vector2 _velocity;

  Bullet({
    required Vector2 position,
    required Vector2 velocity,
    required double angle,
    double initialSpeed = 0,
  }) : super(
          position: position,
          size: Vector2.all(4),
          anchor: Anchor.center,
        ) {
    velocity.rotate(angle);
    _velocity = velocity;
    _speed = initialSpeed + 150;
  }

  @override
  Future<void> onLoad() async {
    FlameAudio.play('missile_shot.wav');
    FlameAudio.play('missile_flyby.wav');
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
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

    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      FlameAudio.play('missile_hit.wav');
      removeFromParent(); // gameRef.remove(this);
      gameRef.player.shake();
    }
  }
}
