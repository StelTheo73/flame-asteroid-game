import 'package:flutter/material.dart';

import '../utils/controller.dart';
import 'levels.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Controller controller = Controller();
  late final List<dynamic> levels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Asteroids Game'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            LevelPage(),
          ],
        ),
      ),
    );
  }
}
