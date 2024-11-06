import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

import 'pages/game.dart';
import 'pages/home.dart';
import 'pages/routes.dart';
import 'utils/config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Configuration.app['name']! as String,
      routes: <String, WidgetBuilder>{
        AppRoute.home.route: (BuildContext context) => const HomePage(),
        AppRoute.game.route: (BuildContext context) {
          final int levelId =
              ModalRoute.of(context)!.settings.arguments! as int;
          return AsteroidGamePage(levelId: levelId);
        },
      },
      initialRoute: AppRoute.home.route,
    );
  }
}

Future<void> main() async {
  await Configuration.setup();

  runApp(
    const MyApp(),
  );
}
