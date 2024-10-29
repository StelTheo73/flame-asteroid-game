import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

/// Particle Generator Function for creation of explosion simulation
class ParticleGenerator {
  static final Random random = Random();

  static ParticleSystemComponent createParticleExplosion(
      {required Vector2 position}) {
    return ParticleSystemComponent(
      position: position,
      particle: ComposedParticle(
        children: List<Particle>.generate(
          45,
          (int i) {
            final double angle = random.nextDouble() * 2 * pi;
            final Vector2 acceleration =
                Vector2(cos(angle), sin(angle)) * random.nextDouble() * 50;
            final Vector2 speed =
                Vector2(cos(angle), sin(angle)) * random.nextDouble() * 10;
            return AcceleratedParticle(
              acceleration: acceleration,
              speed: speed,
              child: ScalingParticle(
                child: CircleParticle(
                  paint: Paint()..color = Colors.red,
                  radius: 2,
                ),
              ),
            );
          },
        ),
        lifespan: 2,
      ),
    );
  }

  static ParticleSystemComponent createSpriteParticleExplosion(
      {required Images images, required Vector2 position}) {
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
