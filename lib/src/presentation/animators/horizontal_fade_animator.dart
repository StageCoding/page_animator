import 'dart:math';

import 'package:flutter/material.dart';
import 'package:page_animator/src/presentation/animators/animator.dart';

class HorizontalFadeAnimator extends Animator {
  final bool inverse;

  const HorizontalFadeAnimator({this.inverse = false});

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
          builder: (context, value, child) {
            var ordered =
                orderedChildren(children, value.floor(), centerChildIndex)
                    .toList();

            if (!inverse) ordered = ordered.reversed.toList();

            return Stack(
              children: ordered.map((child) {
                final id = children.indexOf(child);

                var xPos =
                    (id - value + centerChildIndex + 0.5) % children.length -
                        centerChildIndex -
                        0.5;

                if (inverse) {
                  if (xPos <= 0 && xPos > -1) xPos = 0;
                } else {
                  if (xPos >= 0 && xPos < 1) xPos = 0;
                }

                return Positioned(
                  left: xPos * pageWidth,
                  width: pageWidth,
                  top: 0,
                  bottom: 0,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            if (xPos > -0.99)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 10,
                                blurRadius: 20,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              )
                          ],
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      Container(
                        color: xPos > 0 && xPos <= 1
                            ? Colors.black.withOpacity(
                                max(0.0, (1 - pageOffset.value % 1) * 0.3))
                            : null,
                        child: child,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
