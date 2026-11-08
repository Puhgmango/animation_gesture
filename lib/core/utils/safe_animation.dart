import 'package:animation_gesture_demo/core/errors/animation_exception.dart';
import 'package:flutter/scheduler.dart';

/// Chạy một animation và xử lý ngoại lệ tập trung.
///
/// - Trả về `true` nếu animation chạy xong.
/// - Trả về `false` nếu bị huỷ (controller bị `stop()` hoặc `dispose()`);
///   đây là tình huống bình thường, không phải lỗi.
/// - Ném [AnimationException] với mọi lỗi khác.
Future<bool> runAnimationSafely(TickerFuture Function() start) async {
  try {
    await start().orCancel;
    return true;
  } on TickerCanceled {
    return false;
  } on Object catch (error) {
    throw AnimationException('Không thể chạy animation.', cause: error);
  }
}
