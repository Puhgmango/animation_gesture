import 'package:flutter/widgets.dart';

/// Hỗ trợ tôn trọng cài đặt "Giảm chuyển động" (Reduce motion) của hệ điều hành.
extension MotionContext on BuildContext {
  /// `true` khi người dùng đã tắt animation trong cài đặt hệ thống.
  bool get isMotionReduced => MediaQuery.disableAnimationsOf(this);

  /// Trả về [Duration.zero] nếu cần giảm chuyển động, ngược lại giữ nguyên.
  Duration motionDuration(Duration duration) =>
      isMotionReduced ? Duration.zero : duration;
}
