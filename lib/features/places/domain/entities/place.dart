import 'package:flutter/foundation.dart';

/// Địa điểm du lịch.
@immutable
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.emoji,
    required this.rating,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String id;
  final String name;
  final String location;
  final String description;
  final String emoji;
  final double rating;

  /// Màu ARGB dùng cho nền gradient của ảnh minh hoạ.
  final int gradientStart;
  final int gradientEnd;
}
