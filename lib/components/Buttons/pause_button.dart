import 'package:flutter/material.dart';

import '../../pages/routes.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 10,
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: onPressed,
            child: const Icon(Icons.pause),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await Navigator.popAndPushNamed(context, AppRoute.home.route);
              // Navigator.of(context)
              // .pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}
