import 'dart:math';

import 'package:flame/components.dart';

/// Generalized utility methods for Vector based problems.
///
///
class Utils {
  /// Generate a random location for any Component
  ///
  ///
  static Vector2 generateRandomPosition(Vector2 screenSize, Vector2 margins) {
    Vector2 result = Vector2.zero();
    Random randomGenerator = Random();
    //
    // Generate a new random position
    result = Vector2(
        randomGenerator
                .nextInt(screenSize.x.toInt() - 2 * margins.x.toInt())
                .toDouble() +
            margins.x,
        randomGenerator
                .nextInt(screenSize.y.toInt() - 2 * margins.y.toInt())
                .toDouble() +
            margins.y);

    return result;
  }

  /// Generate a random direction and velocity for any Component
  ///
  /// This creates a directional vector that is randmized over a unit circle
  /// the [min] and [max] are used to create a range for the actual speed
  /// component of the vector
  static Vector2 generateRandomVelocity(Vector2 screenSize, int min, int max) {
    Vector2 result = Vector2.zero();
    Random randomGenerator = Random();
    double velocity;

    while (result == Vector2.zero()) {
      result = Vector2(
          (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble(),
          (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble());
    }
    result.normalize();
    velocity = (randomGenerator.nextInt(max - min) + min).toDouble();

    return result * velocity;
  }

  /// Check if the given [position] is out of bounds of the passed in
  /// [bounds] object usually representing a screen size or some bounding
  /// area
  ///
  static bool isPositionOutOfBounds(Vector2 bounds, Vector2 position) {
    if (position.x >= bounds.x ||
        position.x <= 0 ||
        position.y <= 0 ||
        position.y >= bounds.y) {
      return true;
    }

    return false;
  }

  static Vector2 wrapPosition(Vector2 bounds, Vector2 position) {
    Vector2 result = Vector2.zero();

    if (position.x >= bounds.x) {
      result.x = 0;
    } else if (position.x <= 0) {
      result.x = bounds.x;
    } else {
      result.x = position.x;
    }

    if (position.y >= bounds.y) {
      result.y = 0;
    } else if (position.y <= 0) {
      result.y = bounds.y;
    } else {
      result.y = position.y;
    }

    return result;
  }
}
