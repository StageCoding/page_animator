import 'package:page_animator/src/presentation/animators/animator.dart';
import 'package:page_animator/src/presentation/animators/horizontal_fade_animator.dart';
import 'package:page_animator/src/presentation/animators/horizontal_simple_animator.dart';
import 'package:page_animator/src/presentation/animators/no_animation_animator.dart';
import 'package:page_animator/src/presentation/animators/vertical_fade_animator.dart';
import 'package:page_animator/src/presentation/animators/vertical_simple_animator.dart';

enum PageAnimatorType {
  noAnimation('No animation', NoAnimationAnimator()),
  horizontalSimple('Horizontal - Simple', HorizontalSimpleAnimator()),
  horizontalFade('Horizontal - Fade', HorizontalFadeAnimator()),
  horizontalFadeInverse(
      'Horizontal - Fade Inverse', HorizontalFadeAnimator(inverse: true)),
  verticalSimple('Vertical - Simple', VerticalSimpleAnimator()),
  // verticalContinuous(vertical: true),
  verticalFade('Vertical - Fade', VerticalFadeAnimator()),
  verticalFadeInverse(
      'Vertical - Fade Inverse', VerticalFadeAnimator(inverse: true)),
  // pageFlip,
  ;

  final String name;
  final Animator animator;

  const PageAnimatorType(this.name, this.animator);
}
