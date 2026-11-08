import 'dart:async';

import 'package:animation_gesture_demo/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Điểm vào ứng dụng. Mọi lỗi chưa bắt được đều được ghi nhận tại đây.
void main() {
  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Lỗi phát sinh trong framework (build, layout, paint...).
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      };

      runApp(const AnimationGestureApp());
    },
    // Lỗi bất đồng bộ không có try/catch.
    (Object error, StackTrace stackTrace) {
      debugPrint('Unhandled error: $error\n$stackTrace');
    },
  );
}
