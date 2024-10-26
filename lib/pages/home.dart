import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../game.dart';

class HomePage extends Component with HasGameRef<AsteroidGame> {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Title
    final TextComponent<TextPaint> title = TextComponent(
      text: 'Asteroid Game',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    )
      ..anchor = Anchor.topCenter
      ..x = gameRef.size.x / 2
      ..y = 50;
    add(title);

    // Buttons
    final TextPaint buttonStyle = TextPaint(
      style: const TextStyle(
        fontSize: 24.0,
        color: Colors.white,
      ),
    );

    final TextComponent<TextPaint> levelButton = TextComponent(
      text: 'Select Level',
      textRenderer: buttonStyle,
    )
      ..anchor = Anchor.center
      ..x = gameRef.size.x / 2
      ..y = gameRef.size.y / 2 - 50
      ..add((TapGestureRecognizer()
        ..onTap = () => gameRef.router.pushNamed('level')) as Component);
    add(levelButton);

    final TextComponent<TextPaint> settingsButton = TextComponent(
      text: 'Settings',
      textRenderer: buttonStyle,
    )
      ..anchor = Anchor.center
      ..x = gameRef.size.x / 2
      ..y = gameRef.size.y / 2
      ..add((TapGestureRecognizer()
        ..onTap = () => gameRef.router.pushNamed('settings')) as Component);
    add(settingsButton);
  }
}
