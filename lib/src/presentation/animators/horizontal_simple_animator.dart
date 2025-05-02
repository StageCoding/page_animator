import 'dart:math';

import 'package:flutter/material.dart';
import 'package:page_animator/src/presentation/animators/animator.dart';
import 'dart:ui' as ui;

class HorizontalSimpleAnimator extends Animator {
  const HorizontalSimpleAnimator();

  @override
  Widget buildContentLayout(
    BuildContext context,
    List<Widget> children,
    int centerChildIndex,
    ValueNotifier<double> pageOffset, {
    double sizeFactor = 1,
    int? minValue,
    int? maxValue,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final pageHeight = constraints.maxHeight;

        return ValueListenableBuilder(
          valueListenable: pageOffset,
          builder: (context, value, child) => Stack(
            alignment: Alignment.center,
            children: [
              // TODO (later) Implement BottomProgress
              // Positioned(
              //   bottom: MediaQuery.of(context).padding.bottom,
              //   left: pageWidth * (1 - ui.lerpDouble(0.8, 1, sizeFactor)!) / 2,
              //   right: pageWidth * (1 - ui.lerpDouble(0.8, 1, sizeFactor)!) / 2,
              //   child: AnimatedSwitcher(
              //     duration: const Duration(milliseconds: 300),
              //     child:
              //         sizeFactor < 0.5 ? const BottomProgress() : Container(),
              //   ),
              // ),
              ...children.map((child) {
                final id = children.indexOf(child);

                var xPos =
                    (id - value + centerChildIndex + 0.5) % children.length -
                        centerChildIndex -
                        0.5;

                if (minValue != null && minValue - 0.5 - value >= xPos) {
                  xPos += children.length;
                } else if (maxValue != null && maxValue + 0.5 - value <= xPos) {
                  xPos -= children.length;
                }

                if (sizeFactor == 1) {
                  return Positioned(
                    left: xPos * pageWidth,
                    width: pageWidth,
                    top: 0,
                    bottom: 0,
                    child: child,
                  );
                }

                final emphasize = max(min(-xPos.abs() + 1, 1), 0);

                final pageScale =
                    ui.lerpDouble(0.6 + emphasize * 0.1, 1, sizeFactor)!;
                final margin = pageWidth * 0.08;
                final widthWithMargin = pageWidth + margin * 2;

                return Positioned(
                  left: (1 - pageScale) * pageWidth / 2 +
                      xPos * widthWithMargin * pageScale,
                  width: pageWidth * pageScale,
                  height: pageScale * pageHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                        color: const Color(0xFF555770),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 3,
                          blurRadius: 9,
                        )
                      ],
                    ),
                    child: FittedBox(
                      child: SizedBox(
                        height: pageHeight,
                        width: pageWidth,
                        child: child,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
