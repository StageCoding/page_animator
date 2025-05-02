# Page Animator

A Flutter package that provides smooth page transitions and animations with customizable effects. Perfect for creating engaging user interfaces with horizontal page navigation.

## Features

- Multiple animation types for page transitions, switchable in realtime
- Infinite scrolling in both directions, with ability to set bounds in realtime
- Animated switcher - tap on a page, and it will zoom out, similar to Kindle reader

## Animation Types

The package supports various animation types through `PageAnimatorType`. Here's a comprehensive list of all available animations:

| Preview | Preview | Preview |
|---------|---------|---------|
| <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/animated_switcher-ezgif.com-resize.gif" width="180"> | <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/no_animation-ezgif.com-resize.gif" width="180"> | <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/horizontal_simple-ezgif.com-resize.gif" width="180"> |
| [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/animated_switcher.gif)<br>`animatedSwitcher` - Animated switcher transition | [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/no_animation.gif)<br>`noAnimation` - No animation effect, instant page switch | [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/horizontal_simple.gif)<br>`horizontalSimple` - Simple horizontal slide transition |
| <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/horizontal_fade-ezgif.com-resize.gif" width="180"> | <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/horizontal_fade_inverse-ezgif.com-resize.gif" width="180"> | <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/vertical_simple-ezgif.com-resize.gif" width="180"> |
| [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/horizontal_fade.gif)<br>`horizontalFade` - Horizontal slide with fade effect | [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/horizontal_fade_inverse.gif)<br>`horizontalFadeInverse` - Horizontal slide with inverse fade effect | [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/vertical_simple.gif)<br>`verticalSimple` - Simple vertical slide transition |
| <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/vertical_fade-ezgif.com-resize.gif" width="180"> | <img src="https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/vertical_fade_inverse-ezgif.com-resize.gif" width="180"> | |
| [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/vertical_fade.gif)<br>`verticalFade` - Vertical slide with fade effect | [Uncompressed gif](https://raw.githubusercontent.com/StageCoding/page_animator/refs/heads/master/images/vertical_fade_inverse.gif)<br>`verticalFadeInverse` - Vertical slide with inverse fade effect | |

You can change the animation type dynamically using the controller:

```dart
pageAnimatorController.type.value = PageAnimatorType.verticalFade;
```

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  page_animator: ^1.0.0
```

## Usage

1. Import the package:

```dart
import 'package:page_animator/page_animator.dart';
```

2. Create a `PageAnimatorController`:

```dart
final pageAnimatorController = PageAnimatorController(
  type: PageAnimatorType.horizontalFade,
);
```

3. Use the `PageAnimator` widget:

```dart
PageAnimator(
  controller: pageAnimatorController,
  onPageChanged: (int currentPage) {
    print('Page offset: $currentPage');
  },
  leftMostIndex: -3,
  rightMostIndex: 3,
  children: [
    // Your page widgets here
  ],
)
```

### Page Bounds

The `PageAnimator` widget allows you to set bounds for page navigation using `leftMostIndex` and `rightMostIndex` parameters:

- `leftMostIndex`: The minimum page offset that can be reached by swiping left
- `rightMostIndex`: The maximum page offset that can be reached by swiping right

These bounds can be changed in realtime, allowing you to dynamically control the navigation range. For example:

```dart
// Initially allow navigation indefinitelly
PageAnimator(
  leftMostIndex: null,
  rightMostIndex: null,
  // ... other parameters
)

// Later, you can update the bounds
PageAnimator(
  leftMostIndex: -3,
  rightMostIndex: 3,
  // ... other parameters
)
```

When a bound is reached, the page will stop scrolling in that direction, providing a natural end to the navigation.

### Example

Here's a complete example showing how to use the package:

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final pageAnimatorController = PageAnimatorController(
    type: PageAnimatorType.horizontalFade,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageAnimator(
        controller: pageAnimatorController,
        onPageChanged: (int currentPage) {
          print('Page offset: $currentPage');
        },
        leftMostIndex: -3,
        rightMostIndex: 3,
        children: [
          for (final page in List.generate(3, (index) => index))
            _buildPage(page),
        ],
      ),
    );
  }

  Widget _buildPage(int page) {
    return Scaffold(
      body: Center(
        child: Text('Page $page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pageAnimatorController.animateToOffset(1),
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
```

## Controller Methods

The `PageAnimatorController` provides several methods to control page transitions:

- `animateToOffset(int offset)`: Animate to a specific page offset
- `type`: Change the animation type dynamically
- `switcherActive`: Control the page switcher state

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
