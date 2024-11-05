import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class Configuration {
  static late final bool debugMode;
  static late final bool music;
  // static late final Map<String, int> resolution;

  static Future<void> setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    Flame.device.fullScreen();
    Flame.device.setPortrait();
    await Configuration._loadConfiguration();
    await Configuration._loadAssets();
    // await Configuration._loadResolution();
  }

  static Future<void> _loadAssets() async {
    await FlameAudio.audioCache.load('race_to_mars.mp3');
    await FlameAudio.audioCache.load('missile_shot.wav');
    await FlameAudio.audioCache.load('missile_flyby.wav');
    await FlameAudio.audioCache.load('missile_hit.wav');
  }

  static Future<void> _loadConfiguration() async {
    final String yamlString = await rootBundle.loadString('config/config.yml');
    final dynamic yaml = loadYaml(yamlString) ?? <String, dynamic>{};
    Configuration.debugMode = yaml['debugMode'] as bool? ?? false;
    Configuration.music = yaml['music'] as bool? ?? false;
  }

  static Future<List<dynamic>> loadLevels() async {
    final String yamlString =
        await rootBundle.loadString('assets/levels/levels.yml');
    final dynamic yaml = loadYaml(yamlString);
    return yaml['game_data']['levels'] as List<dynamic>;
  }

  // static Future<void> _loadResolution() async {
  //   final String yamlString =
  //       await rootBundle.loadString('assets/levels/levels.yml');
  //   final dynamic yaml = loadYaml(yamlString);
  //   resolution = yaml['game_data']['resolution'] as Map<String, int>;
  // }
}
