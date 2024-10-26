import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';

import 'components/Buttons/PauseButton.dart';
import 'game.dart';
import 'utils/config.dart';

class AsteroidGameWidget extends StatefulWidget {
  const AsteroidGameWidget({super.key, this.debugMode = false});

  final bool debugMode;

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
    if (!widget.debugMode) {
      FlameAudio.bgm.play('race_to_mars.mp3');
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

Future<void> loadAssets() async {
  await FlameAudio.audioCache.load('race_to_mars.mp3');
  await FlameAudio.audioCache.load('missile_shot.wav');
  await FlameAudio.audioCache.load('missile_flyby.wav');
  await FlameAudio.audioCache.load('missile_hit.wav');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setPortrait();
  await loadAssets();

  final Configuration configuration = Configuration();
  await configuration.loadConfiguration();

  runApp(
    AsteroidGameWidget(
      debugMode: configuration.debugMode,
    ),
  );
}
