import 'package:flutter/material.dart';
import 'package:page_animator/src/presentation/animators/animator.dart';

class NoAnimationAnimator extends Animator {
  const NoAnimationAnimator();

  @override
  Widget buildContentLayout(
    BuildContext context,
    List<Widget> children,
    int centerChildIndex,
    ValueNotifier<double> pageOffset,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;

        return ValueListenableBuilder(
          valueListenable: pageOffset,
          builder: (context, value, child) => Stack(
            children: children.map((child) {
              final id = children.indexOf(child);

              final xPos = (id - value.round() + centerChildIndex + 1) %
                      children.length -
                  centerChildIndex -
                  1;

              return Positioned(
                left: xPos * pageWidth,
                width: pageWidth,
                top: 0,
                bottom: 0,
                child: child,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
