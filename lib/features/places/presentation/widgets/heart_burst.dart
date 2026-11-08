import 'dart:async';

import 'package:animation_gesture_demo/core/constants/animation_constants.dart';
import 'package:animation_gesture_demo/core/errors/animation_exception.dart';
import 'package:animation_gesture_demo/core/utils/motion_context.dart';
import 'package:animation_gesture_demo/core/utils/safe_animation.dart';
import 'package:flutter/material.dart';

/// Trái tim lớn bật lên rồi mờ dần ở giữa ảnh khi chạm đúp.
///
/// Mỗi lần [trigger] thay đổi, hiệu ứng được phát lại một lần.
/// Widget bọc trong [IgnorePointer] nên không chặn thao tác bên dưới.
class HeartBurst extends StatefulWidget {
  const HeartBurst({required this.trigger, super.key});

  final int trigger;

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.slow,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 40),
    ]).animate(_controller);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 55),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(HeartBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) unawaited(_play());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (context.isMotionReduced) return;
    try {
      await runAnimationSafely(() => _controller.forward(from: 0));
    } on AnimationException catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: const Icon(
            Icons.favorite,
            size: 96,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 16, color: Colors.black38)],
          ),
        ),
      ),
    );
  }
}
