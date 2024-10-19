import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum LifeBarPlacement {
  left,
  center,
  right,
}

class LifeBar extends PositionComponent {
  //
  // Constructor
  LifeBar.initData(
    Vector2 parentSize, {
    Vector2? size,
    int? warningThreshold,
    Color? warningColor,
    Color? healthyColor,
    double? barOffset,
    LifeBarPlacement? placement,
  }) {
    _parentSize = parentSize;
    _size = size ?? Vector2(parentSize.x, 5);
    _warningThreshold = warningThreshold ?? _healthThreshold;
    _warningColor = warningColor ?? _redColor;
    _healthyColor = healthyColor ?? _greenColor;
    _barToParentOffset = barOffset ?? _defaultBarOffset;
    _placement = placement ?? LifeBarPlacement.left;
    _healthyColorStyled = Paint()
      ..color = _healthyColor
      ..style = PaintingStyle.fill;
    _warningColorStyled = Paint()
      ..color = _warningColor
      ..style = PaintingStyle.fill;

    anchor = Anchor.center;

    _updateCurrentColor();
  }
  //
  // Constant Attributes
  static const Color _redColor = Colors.red;
  static const Color _greenColor = Colors.green;

  static final Paint _backgroundFillColor = Paint()
    ..color = Colors.grey.withOpacity(0.35)
    ..style = PaintingStyle.fill;
  static final Paint _outlineColor = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static const int _maxLife = 100;
  static const int _healthThreshold = 25;

  // Offset from the edge of the parent component (in pixels)
  static const double _defaultBarOffset = 2;

  //
  // Attributes
  int _life = _maxLife;
  late Paint _color;
  late List<RectangleComponent> _lifeBarElements;

  //
  // Attributes of constructor
  late Vector2 _parentSize;
  late Vector2 _size;
  late int _warningThreshold;
  late Color _warningColor;
  late Color _healthyColor;
  // The number of pixels the bar is offset from the edge of the parent component
  late double _barToParentOffset;
  // The placement of the bar in relation to the parent component
  late LifeBarPlacement _placement;
  late Paint _healthyColorStyled;
  late Paint _warningColorStyled;

  //
  // Life
  int get currentLife => _life;

  set currentLife(int value) {
    if (value > _maxLife) {
      _life = _maxLife;
    } else if (value < 0) {
      _life = 0;
    } else {
      _life = value;
    }
  }

  void incrementCurrentLifeBy(int value) {
    currentLife += value;
  }

  void decrementCurrentLifeBy(int value) {
    currentLife -= value;
  }

  //
  // Colors
  Color get warningColor => _warningColor;

  Color get healthyColor => _healthyColor;

  void _updateCurrentColor() {
    _color =
        _life <= _warningThreshold ? _warningColorStyled : _healthyColorStyled;
  }

  //
  // Positioning
  Vector2 _calculateBarPosition() {
    Vector2 result;

    switch (_placement) {
      case LifeBarPlacement.left:
        {
          result = Vector2(0, -_size.y - _barToParentOffset);
        }
        break;
      case LifeBarPlacement.center:
        {
          result = Vector2(
              _parentSize.x - _size.x / 2, -_size.y - _barToParentOffset);
        }
        break;
      case LifeBarPlacement.right:
        {
          result =
              Vector2(_parentSize.x - _size.x, -_size.y - _barToParentOffset);
        }
        break;
    }

    return result;
  }

  @override
  Future<void> onLoad() async {
    _lifeBarElements = [
      // Outline
      RectangleComponent(
        position: _calculateBarPosition(),
        size: _size,
        angle: 0,
        paint: _outlineColor,
      ),
      // Semi-transparent background
      RectangleComponent(
        position: _calculateBarPosition(),
        size: _size,
        angle: 0,
        paint: _backgroundFillColor,
      ),
      // Life percentage
      RectangleComponent(
        position: _calculateBarPosition(),
        size: Vector2(10, _size.y),
        angle: 0,
        paint: _color,
      ),
    ];

    addAll(_lifeBarElements);

    super.onLoad();
  }

  @override
  void update(double dt) {
    _updateCurrentColor();
    _lifeBarElements[2].paint = _color;
    _lifeBarElements[2].size.x = (_size.x * _life) / _maxLife;

    super.update(dt);
  }
}
