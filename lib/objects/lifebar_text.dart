import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class LifeBarText extends TextComponent<TextPaint> {
  LifeBarText(int ordinalNumber) {
    _ordinalNumber = ordinalNumber;
  }

  /// formatting of the text data
  /// more information here:
  /// https://api.flutter.dev/flutter/intl/NumberFormat-class.html
  ///
  ///

  final TextPaint textBallStats = TextPaint(
    style: const TextStyle(color: Colors.red, fontSize: 10),
  );
  intl.NumberFormat ordinalFormatter = intl.NumberFormat('000', 'en_US');
  intl.NumberFormat healthDataFormatter = intl.NumberFormat('000', 'en_US');

  int _ordinalNumber = 0;
  int healthData = 0;

  @override
  Future<void> onLoad() async {
    textRenderer = textBallStats;
    await super.onLoad();
  }

  @override
  void update(double dt) {
    /// format the text into the life-health string
    text = '#${ordinalFormatter.format(_ordinalNumber)}'
        ' - ${healthDataFormatter.format(healthData)}%';
    super.update(dt);
  }
}
