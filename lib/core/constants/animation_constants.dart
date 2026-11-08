import 'package:flutter/animation.dart';

/// Các hằng số dùng chung cho chuyển động.
///
/// Thời lượng ngắn (200–500 ms) giúp phản hồi cảm nhận được
/// nhưng không làm người dùng phải chờ.
abstract final class AnimationConstants {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve settleCurve = Curves.easeOutBack;
  static const Curve slideAwayCurve = Curves.easeIn;

  /// Khoảng vuốt ngang tối thiểu (logical pixel) để thực hiện hành động.
  static const double dismissThreshold = 100;
}
