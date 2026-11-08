import 'package:animation_gesture_demo/core/constants/animation_constants.dart';
import 'package:animation_gesture_demo/core/utils/motion_context.dart';
import 'package:flutter/material.dart';

/// Icon kèm huy hiệu đếm; con số đổi bằng hiệu ứng phóng to.
class FavoriteBadgeIcon extends StatelessWidget {
  const FavoriteBadgeIcon({
    required this.count,
    required this.icon,
    super.key,
  });

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(AnimationConstants.fast);

    return Badge(
      isLabelVisible: count > 0,
      label: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text('$count', key: ValueKey<int>(count)),
      ),
      child: Icon(icon),
    );
  }
}
