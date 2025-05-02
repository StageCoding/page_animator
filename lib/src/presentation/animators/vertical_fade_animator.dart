import 'dart:math';

import 'package:flutter/material.dart';
import 'package:page_animator/src/presentation/animators/animator.dart';

class VerticalFadeAnimator extends Animator {
  final bool inverse;

  const VerticalFadeAnimator({this.inverse = false}) : super(vertical: true);

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
          builder: (context, value, child) {
            var ordered =
                orderedChildren(children, value.floor(), centerChildIndex)
                    .toList();

            if (!inverse) ordered = ordered.reversed.toList();

            return Stack(
              children: ordered.map((child) {
                final id = children.indexOf(child);

                var yPos =
                    (id - value + centerChildIndex + 1) % children.length -
                        centerChildIndex -
                        1;

                if (inverse) {
                  if (yPos <= 0 && yPos > -1) yPos = 0;
                } else {
                  if (yPos >= 0 && yPos < 1) yPos = 0;
                }

                return Positioned(
                  top: yPos * pageHeight,
                  height: pageHeight,
                  left: 0,
                  right: 0,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            if (yPos > -0.99)
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
                        color: yPos > 0 && yPos <= 1
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
