import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:page_animator/page_animator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:page_animator/src/presentation/animators/horizontal_simple_animator.dart';

/// {@template PageAnimator}
/// Builds the widget that contains the pages and handles the drag gestures and
/// page rendering in a chosen type.
/// {@endtemplate}
class PageAnimator extends HookWidget {
  final List<Widget> children;

  late final centerChildIndex = children.length ~/ 2;

  /// {@template PageAnimator.onPageChanged}
  /// Called when the page is swiped.
  /// {@endtemplate}
  final void Function(int currentChildIndex) onPageChanged;

  /// {@template PageAnimator.hasPrevious}
  /// The first page user can go to.
  /// {@endtemplate}
  final int? leftMostIndex;

  /// {@template PageAnimator.hasNext}
  /// The last page user can go to.
  /// {@endtemplate}
  final int? rightMostIndex;

  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  /// {@template PageAnimator.onDragAnimationStart}
  /// Called when the animation starts, but user is not dragging. Page is
  /// chaging on its own.
  /// {@endtemplate}
  final VoidCallback? onDragAnimationStart;

  final VoidCallback? onDragAnimationEnd;

  final PageAnimatorController controller;

  final _switcherAnimator = const HorizontalSimpleAnimator();

  PageAnimator({
    super.key,
    required this.children,
    required this.onPageChanged,
    required this.leftMostIndex,
    required this.rightMostIndex,
    required this.controller,
    this.onDragStart,
    this.onDragEnd,
    this.onDragAnimationStart,
    this.onDragAnimationEnd,
  });

  double _addAndClampOffset(double startPageOffset, double offset) {
    final res = startPageOffset + offset;
    if (leftMostIndex != null && res < leftMostIndex!) {
      return leftMostIndex!.toDouble();
    } else if (rightMostIndex != null && res > rightMostIndex!) {
      return rightMostIndex!.toDouble();
    } else {
      return res;
    }
  }

  void _animateToOffset({
    required Tween<double> transitionTween,
    required AnimationController animationController,
    required double currentPageOffset,
    required double endPageOffset,
  }) {
    onDragAnimationStart?.call();

    transitionTween.begin = currentPageOffset;
    transitionTween.end = endPageOffset;

    animationController.duration = Duration(
      milliseconds:
          (max((transitionTween.end! - transitionTween.begin!).abs(), 0.3) *
                  300)
              .round(),
    );

    animationController.forward(from: 0);
  }

  void _startInfiniteScroll(
    AnimationController animationController,
    Tween<double> transitionTween,
    ValueNotifier<double> pageOffset,
    double endVelocity,
    ValueNotifier<double> startPageOffset,
  ) {
    transitionTween.begin = pageOffset.value;
    transitionTween.end =
        _addAndClampOffset(pageOffset.value, -endVelocity / 600);

    animationController.duration = Duration(
      milliseconds:
          (max((transitionTween.end! - transitionTween.begin!).abs(), 0.3) *
                  130)
              .round(),
    );

    animationController.forward(from: 0);

    void listener() {
      if (animationController.value > 0.99) {
        final offset = transitionTween.evaluate(animationController);

        animationController.stop();
        _animateToOffset(
          transitionTween: transitionTween,
          animationController: animationController,
          currentPageOffset: offset,
          endPageOffset: offset.roundToDouble(),
        );

        animationController.removeListener(listener);
      }
    }

    animationController.addListener(listener);
  }

  final _pointerDownInfo = <int, (Offset, DateTime)>{};

  @override
  Widget build(BuildContext context) {
    final pageOffset = useListenable(controller.page);
    final switcherActive = useListenable(controller.switcherActive);

    /// Whether the user is currently dragging the page. For now it is used to
    /// differentiate the selection behavior (if it should update the selection
    /// even if the selection is not changed)
    final dragging = useState(false);

    /// When dragging, the page offset when the drag started.
    final startPageOffset = useState(0.0);

    /// The drag offset since the drag started. It is mostly the difference between
    /// the current drag position and the drag start position, but it can be
    /// different if user is trying to swipe where there is no page - in that case
    /// page offset will not change, but drag offset will.
    final dragOffset = useState(Offset.zero);

    final sizeFactor = useState(1.0);

    /// When an animation completes, this function stabilizes the page offset
    /// to integer values (it is not an integer - when user starts dragging while
    /// the animation is stil running) and updates the ordered children.
    void finishAnimation() {
      pageOffset.value = pageOffset.value.roundToDouble();
    }

    useEffect(() {
      onPageChanged(controller.page.value.round());

      return null;
    }, [controller.page.value.round()]);

    final animationController = useAnimationController();
    final transitionTween = useMemoized(() {
      final transitionTween = Tween<double>(begin: 0, end: 1);

      final animation = transitionTween.animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      );

      animation.addListener(() {
        pageOffset.value = animation.value;

        if (animation.isCompleted) {
          onDragAnimationEnd?.call();
          if (transitionTween.end != startPageOffset.value) {
            finishAnimation();
          }
        }
      });

      return transitionTween;
    });

    final infiniteAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    useMemoized(() {
      final transitionTween = Tween<double>(begin: 0, end: 1);

      final animation = transitionTween.animate(
        CurvedAnimation(
          parent: infiniteAnimationController,
          curve: Curves.easeInOutCubicEmphasized,
        ),
      );

      animation.addListener(() => sizeFactor.value = animation.value);

      return transitionTween;
    });

    final enableImmersiveSwitch = Platform.isIOS;

    if (!enableImmersiveSwitch) {
      useEffect(() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
            overlays: []);

        return () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: SystemUiOverlay.values);
        };
      }, []);
    }

    useEffect(
      () {
        if (switcherActive.value) {
          infiniteAnimationController.reverse();
          if (enableImmersiveSwitch) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
          }
        } else {
          if (animationController.isAnimating) {
            animationController.stop();
            onDragAnimationEnd?.call();
            finishAnimation();
          }
          infiniteAnimationController.forward();
          if (enableImmersiveSwitch) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
                overlays: []);
          }
        }

        return null;
      },
      [switcherActive.value, controller.type.value],
    );

    controller.animateToOffset = (double offset) {
      if (offset != 1 && offset != -1) throw Exception('Invalid offset value');

      startPageOffset.value = pageOffset.value.roundToDouble();

      final newOffset = _addAndClampOffset(startPageOffset.value, offset);

      if (newOffset == startPageOffset.value) return false;

      _animateToOffset(
        transitionTween: transitionTween,
        animationController: animationController,
        currentPageOffset: pageOffset.value,
        endPageOffset: newOffset,
      );

      return true;
    };

    void onSwipeStart() {
      if (dragging.value || !controller.listenerEnabled) return;

      // Cancel the animation if it is running
      if (animationController.isAnimating) {
        animationController.stop();
        onDragAnimationEnd?.call();
        finishAnimation();
      }

      onDragStart?.call();

      dragging.value = true;
      startPageOffset.value = pageOffset.value;
      dragOffset.value = Offset.zero;
    }

    void onSwipeUpdate(
      DragUpdateDetails details,
      double Function(Offset offset) dragToPageOffset,
    ) {
      if (!dragging.value) return;

      /// If the user is trying to swipe to the left of the first page or to the
      /// right of the last page, the page offset should not change, but the drag
      /// offset should.
      dragOffset.value += details.delta;

      pageOffset.value = _addAndClampOffset(
        startPageOffset.value,
        dragToPageOffset(dragOffset.value),
      );
    }

    void onSwipeEnd(DragEndDetails details, double endVelocity) {
      if (!dragging.value) return;

      dragging.value = false;
      onDragEnd?.call();

      double offset = pageOffset.value.roundToDouble() - startPageOffset.value;
      final double side = (pageOffset.value - startPageOffset.value).sign;

      if (switcherActive.value) {
        if (endVelocity.abs() > 300) {
          _startInfiniteScroll(
            animationController,
            transitionTween,
            pageOffset,
            endVelocity,
            startPageOffset,
          );
          return;
        }
      } else if (endVelocity.abs() > 30) {
        offset = -endVelocity.sign;
        if (side != 0 && side != offset) offset = 0;
      }

      _animateToOffset(
        transitionTween: transitionTween,
        animationController: animationController,
        currentPageOffset: pageOffset.value,
        endPageOffset: _addAndClampOffset(startPageOffset.value, offset),
      );
    }

    final verticalDrag =
        controller.type.value.animator.vertical && !switcherActive.value;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: verticalDrag ? null : (_) => onSwipeStart(),
      onHorizontalDragUpdate: verticalDrag
          ? null
          : (details) => onSwipeUpdate(
                details,
                (Offset offset) => (-offset.dx / 392).clamp(-1, 1),
              ),
      onHorizontalDragEnd: verticalDrag
          ? null
          : (details) =>
              onSwipeEnd(details, details.velocity.pixelsPerSecond.dx),
      onVerticalDragStart: verticalDrag ? (_) => onSwipeStart() : null,
      onVerticalDragUpdate: verticalDrag
          ? (details) => onSwipeUpdate(
                details,
                (Offset offset) => (-offset.dy / 720).clamp(-1, 1),
              )
          : null,
      onVerticalDragEnd: verticalDrag
          ? (details) =>
              onSwipeEnd(details, details.velocity.pixelsPerSecond.dy)
          : null,
      child: Listener(
        onPointerDown: (event) {
          if (dragging.value) return;
          _pointerDownInfo[event.pointer] = (event.position, DateTime.now());
        },
        onPointerUp: (event) {
          if (!controller.listenerEnabled) return;

          if (!_pointerDownInfo.containsKey(event.pointer) ||
              (_pointerDownInfo[event.pointer]!.$1 - event.position).distance >
                  10 ||
              DateTime.now().difference(_pointerDownInfo[event.pointer]!.$2) >
                  const Duration(milliseconds: 200)) {
            return;
          }

          dragging.value = false;

          debugPrint(
              'Pointer up: ${event.localPosition.dx / context.size!.width}');
          switch (event.localPosition.dx / context.size!.width) {
            case < 0.3:
              if (!controller.animateToOffset(-1)) {
                switcherActive.value = !switcherActive.value;
              }
            case > 0.7:
              if (!controller.animateToOffset(1)) {
                switcherActive.value = !switcherActive.value;
              }
            default:
              switcherActive.value = !switcherActive.value;
          }
        },
        child: ValueListenableBuilder(
          valueListenable: sizeFactor,
          builder: (context, value, child) => buildContentLayout(
            context,
            pageOffset,
            sizeFactor.value,
          ),
        ),
      ),
    );
  }

  Widget buildContentLayout(
    BuildContext context,
    ValueNotifier<double> pageOffset,
    double sizeFactor,
  ) {
    if (sizeFactor != 1) {
      return _switcherAnimator.buildContentLayout(
        context,
        children,
        centerChildIndex,
        pageOffset,
        sizeFactor: sizeFactor,
        minValue: leftMostIndex,
        maxValue: rightMostIndex,
      );
    }

    return ValueListenableBuilder<PageAnimatorType>(
      valueListenable: controller.type,
      builder: (context, type, child) => type.animator
          .buildContentLayout(context, children, centerChildIndex, pageOffset),
    );
  }
}
