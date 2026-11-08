import 'package:animation_gesture_demo/features/places/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

/// Widget gốc của ứng dụng.
class AnimationGestureApp extends StatelessWidget {
  const AnimationGestureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Du lịch Việt Nam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
