/// Ngoại lệ miền cho các lỗi liên quan đến animation.
class AnimationException implements Exception {
  const AnimationException(this.message, {this.cause});

  /// Mô tả lỗi dành cho người đọc log.
  final String message;

  /// Nguyên nhân gốc (nếu có).
  final Object? cause;

  @override
  String toString() {
    final suffix = cause == null ? '' : ' (cause: $cause)';
    return 'AnimationException: $message$suffix';
  }
}
