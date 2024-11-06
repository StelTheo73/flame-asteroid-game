import 'package:flutter/material.dart';
import '../utils/config.dart';
import 'routes.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  LevelPageState createState() => LevelPageState();
}

class LevelPageState extends State<LevelPage> {
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
                      Navigator.pushNamed(
                        context,
                        AppRoute.game.route,
                        arguments: snapshot.data![index],
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
