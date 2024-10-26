import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

/// Particle Generator Function for creation of explosion simulation
class ParticleGenerator {
  static ParticleSystemComponent createParticleExplosion(
      {required Vector2 position}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 45,
        lifespan: 1,
        generator: (int i) => AcceleratedParticle(
          acceleration: Utils.randomVector()..scale(200),
          position: position,
          child: CircleParticle(
            paint: Paint()..color = Colors.red,
            radius: 1,
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent createSpriteParticleExplosion(
      {required Images images, required Vector2 position}) {
    position.sub(Vector2(200, 250));
    //position.x = position.x - 200;
    //position.y = position.y + 100;
    return ParticleSystemComponent(
      // use AcceleratedParticle as just a position holder
      particle: AcceleratedParticle(
        lifespan: 2,
        position: position,
        child: SpriteAnimationParticle(
          animation: getBoomAnimation(images),
          size: Vector2(200, 200),
        ),
      ),
    );
  }

  ///
  /// Load up the sprite sheet with an even step time framerate
  static SpriteAnimation getBoomAnimation(Images images) {
    const int columns = 8;
    const int rows = 8;
    const int frames = columns * rows;
    final SpriteSheet spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('boom.png'),
      columns: columns,
      rows: rows,
    );
    final List<Sprite> sprites =
        List<Sprite>.generate(frames, spriteSheet.getSpriteById);
    return SpriteAnimation.spriteList(sprites, stepTime: 0.1);
  }
}
