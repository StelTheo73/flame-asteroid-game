import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class Configuration {
  late bool debugMode;

  Future<void> loadConfiguration() async {
    final String yamlString = await rootBundle.loadString('config/config.yml');
    final yaml = loadYaml(yamlString) ?? {};
    debugMode = yaml['debugMode'] as bool? ?? false;
  }
}
