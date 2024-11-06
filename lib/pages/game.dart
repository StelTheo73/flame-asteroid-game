import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../components/Buttons/pause_button.dart';
import '../game/game.dart';
import '../utils/config.dart';

class AsteroidGamePage extends StatefulWidget {
  AsteroidGamePage({
    super.key,
    required this.levelId,
  });

  final int levelId;
  final bool debugMode = Configuration.debugMode;

  @override
  AsteroidGamePageState createState() => AsteroidGamePageState();
}

class AsteroidGamePageState extends State<AsteroidGamePage> {
  late final AsteroidGame _game;

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
    _game = AsteroidGame(levelId: widget.levelId);
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
    super.dispose();
    await FlameAudio.bgm.audioPlayer.stop();
    await FlameAudio.bgm.stop();
    _game.images.clearCache();
  }
}
