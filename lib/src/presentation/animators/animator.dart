import 'package:flutter/material.dart';

abstract class Animator {
  final bool vertical;

  const Animator({this.vertical = false});

  List<Widget> orderedChildren(
          List<Widget> children, int intOffset, int centerChildIndex) =>
      [
        for (int i = 0; i < children.length; i++)
          children[(intOffset + i - centerChildIndex) % children.length],
      ];

  Widget buildContentLayout(
    BuildContext context,
    List<Widget> children,
    int centerChildIndex,
    ValueNotifier<double> pageOffset,
  );
}
