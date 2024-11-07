import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

import '../objects/asteroid.dart';
import '../objects/bullet.new.dart';
import '../objects/spaceship.dart';
import './controller.dart';

/// Abstraction of a command pattern
/// All commands have access to the controller for any state related data
/// including the ability for complex commands where a command can aggregate
/// other commands.
///
/// Each command has to be added to a [Controller] for management
abstract class Command {
  /// empty constructor
  Command();

  /// The controller to which this command was added
  late final Controller _controller;

  /// getter for the controller
  Controller _getController() {
    return _controller;
  }

  /// this method adds the Command to a specific controller.
  void addToController(Controller controller) {
    _controller = controller;
    controller.addCommand(this);
  }

  /// abstract execute method. All the [Command] derivations will need to put
  /// their work code in here
  void execute();

  /// An optional title for the command for any debug or printing functionality
  String getTitle();
}

/// Specific implementation of the [Command] abstraction that alerts the
/// Spaceship class that a user has tapped the screen
///
/// In this implementation we create additional commands to fire a bullet
/// and to generate the sound for the bullet firing.
class UserTapUpCommand extends Command {
  /// default constructor
  UserTapUpCommand(this.player);

  /// The receiver of this command
  Spaceship player;

  /// work method. We simply fire a bullet in this example
  @override
  void execute() {
    BulletFiredCommand().addToController(_getController());
    BulletFiredSoundCommand().addToController(_getController());
  }

  @override
  String getTitle() {
    return 'UserTapUpCommand';
  }
}

/// Implementation of the [Command] to create a new bullet and add it to the
/// game
class BulletFiredCommand extends Command {
  /// default constructor
  BulletFiredCommand();

  /// work method. We create a bullet based on the Spaceship location and angle
  /// We currently hardcode the bullet type but this could be looked up from
  /// the spaceship.
  @override
  void execute() {
    //
    // velocity vector pointing straight up.
    // Represents 0 radians which is 0 degrees
    final Vector2 velocity = Vector2(0, -1);
    // rotate this vector to the same angle as the player
    velocity.rotate(_getController().getSpaceship().angle);

    // create a bullet with the specific angle and add it to the game
    final BulletBuildContext context = BulletBuildContext()
      ..position =
          _getController().getSpaceship().muzzleComponent.absolutePosition
      ..velocity = velocity
      // ..speed = _getController().getSpaceship().getSpeed() + 150
      ..size = Vector2(4, 4);
    final Bullet myBullet = BulletFactory.create(
        _getController().getSpaceship().getBulletType(), context);
    _getController().add(myBullet);
  }

  @override
  String getTitle() {
    return 'BulletFiredCommand';
  }
}

/// Implementation of the [Command] to create a firing and after-shot bullet
/// sounds
class BulletFiredSoundCommand extends Command {
  BulletFiredSoundCommand();

  @override
  void execute() {
    // sounds used for the shot
    FlameAudio.play('missile_shot.wav', volume: 0.5);
    // layered sounds for missile transition/flyby
    FlameAudio.play('missile_flyby.wav', volume: 0.2);
  }

  @override
  String getTitle() {
    return 'BulletFiredSoundCommand';
  }
}

/// Implementation of the [Command] to notify a bullet that it has been hit
///
class BulletCollisionCommand extends Command {
  /// the bullet being operated on
  late Bullet targetBullet;
  late PositionComponent collisionObject;

  /// deault constructor
  BulletCollisionCommand(Bullet bullet, PositionComponent other) {
    targetBullet = bullet;
    collisionObject = other;
  }

  /// work method. We create a bullet based on the Spaceship location and angle
  /// We currently hardcode the bullet type but this could be looked up from
  /// the speceship.
  @override
  void execute() {
    // let the bullet know its being destroyed.
    targetBullet.onDestroy();
    // remove the bullet from the game
    _getController().remove(targetBullet);
  }

  @override
  String getTitle() {
    return "BulletCollisionCommand";
  }
}

/// Implementation of the [Command] to notify a bullet that it has been hit
///
class AsteroidCollisionCommand extends Command {
  /// the bullet being operated on
  late Asteroid targetAsteroid;
  late PositionComponent collisionObject;

  /// deault constructor
  AsteroidCollisionCommand(Asteroid asteroid, PositionComponent other) {
    targetAsteroid = asteroid;
    collisionObject = other;
  }

  /// work method. We create a bullet based on the Spaceship location and angle
  /// We currently hardcode the bullet type but this could be looked up from
  /// the speceship.
  @override
  void execute() {
    // let the asteroid know its being destroyed.
    targetAsteroid.onDestroy();
    // remove the bullet from the game
    _getController().remove(targetAsteroid);
  }

  @override
  String getTitle() {
    return "AsteroidCollisionCommand";
  }
}
