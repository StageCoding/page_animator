import 'package:flutter/material.dart';
import 'package:page_animator/page_animator.dart';

class PageAnimatorController {
  /// The current page. This is a double because it can be between two
  /// pages while swiping and animating. It can be negative. Starts at 0.
  /// It's never lower that leftMostIndex and never higher than rightMostIndex.
  /// If either of them is null, it means that the bound is not yet calculated,
  /// and it is infinite in that direction.
  final page = ValueNotifier(0.0);

  final ValueNotifier<PageAnimatorType> type;

  /// If true, the single tap on the middle of the screen will activate the switcher,
  /// and the user can switch between pages by tapping the sides of the screen.
  bool get listenerEnabled => _listenersLocked == 0;
  var _listenersLocked = 0;

  VoidCallback lockListener({String? debugName}) {
    _listenersLocked++;

    if (debugName != null) debugPrint('Locked listener: $debugName');

    var unlocked = false;
    return () {
      if (unlocked) return;
      unlocked = true;
      _listenersLocked--;

      if (debugName != null) debugPrint('Unlocked listener: $debugName');
    };
  }

  /// Enables the overview of the pages. You usually want to activate it
  /// when the user taps the middle of the screen.
  final switcherActive = ValueNotifier<bool>(false);

  PageAnimatorController({
    required PageAnimatorType type,
    void Function(bool active)? onSwitcherChange,
  }) : type = ValueNotifier<PageAnimatorType>(type) {
    if (onSwitcherChange != null) {
      switcherActive.addListener(
        () => onSwitcherChange.call(switcherActive.value),
      );
    }
  }

  /// Animates the view to the given offset, which is a value between -1 and 1.
  /// 1 means going to the next page, -1 means going to the previous page.
  bool Function(double offset) animateToOffset = (double offset) {
    throw Exception('Controller not attached to any [PageAnimator] widget');
  };
}
