import 'package:flutter/material.dart';

import '../game/level.dart';
import '../utils/config.dart';

class LevelsWidget extends StatefulWidget {
  @override
  LevelsWidgetState createState() => LevelsWidgetState();
}

class LevelsWidgetState extends State<LevelsWidget> {
  late Future<List<dynamic>> levelsFuture;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() {
    setState(() {
      levelsFuture = Configuration.loadLevels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: levelsFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<dynamic>> snapshot,
      ) {
        if (snapshot.hasData) {
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      'Level ${index + 1}',
                    ),
                    onTap: () {
                      final Level level = Level();
                      level.addAsteroids(
                        snapshot.data![index]['asteroids'] as List<dynamic>,
                      );
                    },
                    subtitle: const Text('Level info here!'),
                  ),
                );
              },
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
