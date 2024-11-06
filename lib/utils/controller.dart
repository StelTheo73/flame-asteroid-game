import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';
import '../objects/spaceship.dart';
import '../pages/routes.dart';
import './command.dart' show Command;
import 'config.dart';

/// Broker is just a simple delegate to take care of processing lists of
/// commands
///
/// We keep two lists:
///  - [_commandList] holds the commands waiting to be executed
///  - [_pendingCommandList] holds all the pending commands. This list is
///    used when the main list is being processed.
class Broker {
  /// explicit default constructor
  Broker();

  final List<Command> _commandList = List<Command>.empty(growable: true);
  final List<Command> _pendingCommandList = List<Command>.empty(growable: true);

  /// add the command to the broker to process
  void addCommand(Command command) {
    print('{Adding command}: $command');
    _pendingCommandList.add(command);
  }

  /// process all the scheduled commands
  void process() {
    /// Process all current commands
    ///
    for (final Command command in _commandList) {
      // execute each command
      print('{Executing command}: $command');
      command.execute();
    }

    /// clear the done list
    _commandList.clear();

    /// move pending into current
    _commandList.addAll(_pendingCommandList);

    /// empty out the pending
    _pendingCommandList.clear();
  }
}

/// The controller is the center piece of the game management.
/// It is responsible for dispatching commands to be executed as well as
/// keeping the state of the game organized.
///
/// The state consists of all the game elements that participate in the
/// messaging.
/// The controller delegates the management of the commands to the [Broker]
/// which in turns schedules the execution of all the pending commands
class Controller extends Component with HasGameRef<AsteroidGame> {
  // the broker which executes all the commands
  final Broker _broker = Broker();

  Future<void> init() async {}

  /// state data
  ///
  Spaceship getSpaceship() {
    return gameRef.player;
  }

  /// at each game update cycle the controller will instruct the broker
  /// to process all outstanding commands
  @override
  void update(double dt) {
    /// execute all the commands
    ///
    _broker.process();
    super.update(dt);
  }

  /// schedule a [command] for processing by delegating it to the broker
  void addCommand(Command command) {
    _broker.addCommand(command);
  }

  Future<void> loadNextLevel() async {
    if (gameRef.levelId == Configuration.levels.length) {
      // TODO(StelTheo73): Add a game completed screen
      Navigator.pushNamed(gameRef.buildContext!, AppRoute.home.route);
      return;
    }
    gameRef.levelId += 1;
    await gameRef.loadLevel();
  }

  bool _isCurrentLevelFinished() {
    return gameRef.asteroids.isEmpty;
  }

  void timerNotification() {
    if (_isCurrentLevelFinished()) {
      loadNextLevel();
    }
  }
}
