import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class Configuration {
  late final bool debugMode;
  late final bool music;

  Future<void> loadConfiguration() async {
    final String yamlString = await rootBundle.loadString('config/config.yml');
    final dynamic yaml = loadYaml(yamlString) ?? <String, dynamic>{};
    debugMode = yaml['debugMode'] as bool? ?? false;
    music = yaml['music'] as bool? ?? false;
  }
}
