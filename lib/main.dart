import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

import 'pages/game.dart';
import 'pages/home.dart';
import 'utils/config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Code a 2D Game in Flame',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomePage(),
        '/game': (BuildContext context) {
          final YamlMap levelData =
              ModalRoute.of(context)!.settings.arguments! as YamlMap;
          return AsteroidGamePage(levelData: levelData);
        },
      },
      initialRoute: '/',
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
