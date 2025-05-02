import 'package:flutter/material.dart';
import 'package:page_animator/page_animator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InfiniteScrollPage(),
    );
  }
}

class InfiniteScrollPage extends StatefulWidget {
  const InfiniteScrollPage({super.key});

  @override
  State<InfiniteScrollPage> createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  final pageAnimatorController = PageAnimatorController(
    type: PageAnimatorType.horizontalFade,
  );
  final GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Page Animator Example'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: pageAnimatorController.type,
            builder: (context, value, child) =>
                DropdownButton<PageAnimatorType>(
              value: value,
              items: PageAnimatorType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) pageAnimatorController.type.value = value;
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: PageAnimator(
              key: key,
              controller: pageAnimatorController,
              onPageChanged: (int currentPage) {
                debugPrint('Page offset: $currentPage');
              },
              leftMostIndex: -3,
              rightMostIndex: 3,
              children: [
                for (final page in List.generate(3, (index) => index))
                  _buildPage(page),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int page) {
    return Scaffold(
      body: Container(
        color: [Colors.red, Colors.blue, Colors.green][page].withAlpha(30),
        child: Center(
          child: Text('Page $page'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pageAnimatorController.animateToOffset(1),
        tooltip: 'Next page',
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
