import 'package:flutter/material.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 10,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: const Icon(Icons.pause),
      ),
    );
  }
}
