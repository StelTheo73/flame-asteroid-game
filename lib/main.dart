import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'components/Buttons/PauseButton.dart';
import 'game/game.dart';
import 'pages/home.dart';
import 'utils/config.dart';

class AsteroidGameWidget extends StatefulWidget {
  AsteroidGameWidget({
    super.key,
  });

  final bool debugMode = Configuration.debugMode;

  @override
  AsteroidGameWidgetState createState() => AsteroidGameWidgetState();
}

class AsteroidGameWidgetState extends State<AsteroidGameWidget> {
  final AsteroidGame _game = AsteroidGame();
  final Map<String, OverlayWidgetBuilder<AsteroidGame>> _overlayBuilderMap =
      <String, OverlayWidgetBuilder<AsteroidGame>>{
    'PauseButton': (BuildContext context, Object? game) {
      return PauseButton(
        onPressed: () async {
          await (game! as AsteroidGame).togglePause();
        },
      );
    },
  };

  @override
  void initState() {
    _game.debugMode = widget.debugMode;

    FlameAudio.bgm.initialize();
    if (!widget.debugMode && Configuration.music) {
      FlameAudio.bgm.play('race_to_mars.mp3', volume: 0.5);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget<AsteroidGame>(
      game: _game,
      overlayBuilderMap: _overlayBuilderMap,
    );
  }

  @override
  Future<void> dispose() async {
    await FlameAudio.bgm.audioPlayer.stop();
    await FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
    _game.images.clearCache();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Code a 2D Game in Flame',
      home: HomePage(),
    );
  }
}

Future<void> main() async {
  await Configuration.setup();

  runApp(
    // AsteroidGameWidget(),
    const MyApp(),
  );
}
