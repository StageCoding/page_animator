import 'package:flutter/material.dart';
import 'package:page_animator/src/presentation/animators/animator.dart';

class VerticalSimpleAnimator extends Animator {
  const VerticalSimpleAnimator() : super(vertical: true);

  @override
  Widget buildContentLayout(
    BuildContext context,
    List<Widget> children,
    int centerChildIndex,
    ValueNotifier<double> pageOffset,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageHeight = constraints.maxHeight;

        return ValueListenableBuilder(
          valueListenable: pageOffset,
          builder: (context, value, child) => Stack(
            children: children.map((child) {
              final id = children.indexOf(child);

              final yPos =
                  (id - value + centerChildIndex + 1) % children.length -
                      centerChildIndex -
                      1;

              return Positioned(
                top: yPos * pageHeight,
                height: pageHeight,
                left: 0,
                right: 0,
                child: Stack(
                  children: [
                    Container(color: Theme.of(context).scaffoldBackgroundColor),
                    child,
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
