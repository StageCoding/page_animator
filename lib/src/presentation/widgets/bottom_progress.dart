import 'package:flutter/material.dart';

class BottomProgress extends StatelessWidget {
  const BottomProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('0'),
        Slider(value: 0, onChanged: (_) {}),
      ],
    );
  }
}
