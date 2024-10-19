import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

import 'components/Buttons/PauseButton.dart';
import 'game.dart';

void main() {
  final AsteroidGame game = AsteroidGame();
  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        'PauseButton': (BuildContext context, Object? game) {
          return PauseButton(
            onPressed: () async {
              await (game! as AsteroidGame).togglePause();
            },
          );
        },
      },
    ),
  );
}
