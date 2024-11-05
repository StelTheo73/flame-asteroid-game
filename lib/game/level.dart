import 'package:flame/components.dart';

import 'game.dart';

class Level {
  // Future<void> setup() async {}

  Future<void> addAsteroids(
    List<dynamic> asteroidData,
  ) async {
    for (final dynamic data in asteroidData) {
      // final Asteroid asteroid = Asteroid(data);

      print('${data['name']}');
      print('${data['position.x']}');
      print('${data['position.y']}');
      print('${data['velocity.x']}');
      print('${data['velocity.y']}');
      print('${data['speed']}');
      print('===================\n');

      // await asteroid.add();
      // this method should use gameRef.add(asteroid)
    }
  }
}
