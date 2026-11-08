# Chủ đề 08: Animation và cử chỉ nâng cao

Ứng dụng **animation_gesture_demo** là một app du lịch nhỏ tên **Du lịch Việt Nam**: người dùng xem danh sách địa điểm, chạm để mở rộng thẻ, chạm đúp để thích, vuốt ngang để ẩn hoặc bỏ thích, và chuyển giữa hai tab Khám phá và Yêu thích. Mỗi thao tác đều có một hiệu ứng chuyển động đi kèm. Dự án được làm để minh họa cách dùng **implicit animation**, **AnimationController** và **cử chỉ (gesture)** trong Flutter sao cho chuyển động hữu ích mà không cản trở thao tác, cùng cách xử lý ngoại lệ chặt chẽ.


---

## 1. Thông tin nhóm

| STT | Họ và tên | MSSV | Phụ trách |
|---|---|---|---|
| 1 | Phạm Viết Duy | 106230008 | Cấu hình dự án và tầng lõi (`core/`), domain, data, controller, xử lý ngoại lệ, README |
| 2 | Cao Minh Phụng | 106230023 | Giao diện và hiệu ứng (`widgets/`, `pages/`, `main.dart`, `app.dart`), dàn ý slide |

Tỷ lệ đóng góp: 50% – 50%. Hai thành viên review chéo phần của nhau qua Pull Request.

Trường Đại học Bách khoa, Khoa Điện tử và Trí tuệ nhân tạo.

## 2. Yêu cầu của đề

**Nội dung:**

- Implicit animation như `AnimatedContainer` và các transition cơ bản.
- `AnimationController` và nguyên tắc quản lý tài nguyên animation.
- Gesture, thời điểm sử dụng animation và tác động đến trải nghiệm người dùng.

**Yêu cầu demo:**

- Tích hợp một hoặc nhiều hiệu ứng chuyển động phù hợp vào chương trình.
- Giải thích cách kích hoạt hiệu ứng và cách bảo đảm chuyển động không gây cản trở thao tác.
- Cấu trúc thư mục chuẩn, clean code, tuân thủ Dart style guide, xử lý ngoại lệ chặt chẽ.

## 3. Tính năng

- Danh sách địa điểm du lịch (dữ liệu mẫu cục bộ, không cần mạng) với thẻ gồm ảnh gradient, tên, tỉnh, đánh giá và mô tả.
- **Chạm vào phần thông tin** của thẻ để mở rộng hoặc thu gọn mô tả.
- **Chạm đúp vào ảnh** để thích: trái tim lớn bật lên rồi mờ dần. Nút tim nhỏ cũng bật hoặc tắt trạng thái thích.
- **Vuốt ngang thẻ**: vuốt đủ xa thì thẻ trượt đi, thu gọn và hiện thông báo **Hoàn tác**; chưa đủ xa thì thẻ nảy về chỗ cũ. Ở tab Khám phá vuốt là ẩn địa điểm, ở tab Yêu thích vuốt là bỏ thích.
- Hai tab **Khám phá** và **Yêu thích**, tab Yêu thích có huy hiệu đếm số mục đã thích.
- Nút khôi phục trên thanh tiêu đề để hiện lại các địa điểm đã ẩn.
- Tôn trọng cài đặt **Giảm chuyển động** của hệ điều hành: khi bật, các hiệu ứng được bỏ qua hoặc có thời lượng bằng 0.

## 4. Kiến trúc hệ thống

```
┌────────────────┐  thao tác    ┌─────────────────┐
│  PlaceCard     │ ───────────► │ PlaceController │
│ (cử chỉ+hiệu ứng)│ ◄─────────── │ (ChangeNotifier)│
└────────────────┘   notify     └─────────────────┘
        ▲                                │
        │ ListenableBuilder              ▼
        └─────── HomePage ── PlaceListView ── PlaceCard
```

| Thành phần | Thư mục | Vai trò |
|---|---|---|
| **Domain** | `lib/features/places/domain/` | Lớp dữ liệu thuần: `Place`, `PlaceNotFoundException`. Không dựng widget. |
| **Data** | `lib/features/places/data/` | `mock_places.dart`: danh sách địa điểm mẫu, dễ thay bằng nguồn dữ liệu thật. |
| **Presentation** | `lib/features/places/presentation/` | `PlaceController` giữ trạng thái; `HomePage` điều phối; các widget `PlaceCard`, `PlaceListView`, `HeartBurst`, `FavoriteBadgeIcon` hiển thị và phát hiệu ứng. |
| **Hằng số** | `lib/core/constants/` | `AnimationConstants`: thời lượng, đường cong và ngưỡng vuốt dùng chung. |
| **Errors** | `lib/core/errors/` | `AnimationException`: ngoại lệ miền cho lỗi animation. |
| **Utils** | `lib/core/utils/` | `runAnimationSafely` (chạy animation và bắt lỗi tập trung), `MotionContext` (tôn trọng cài đặt giảm chuyển động). |

### Luồng dữ liệu một chiều

1. Người dùng chạm đúp ảnh → `PlaceCard` gọi `onToggleFavorite` (chỉ khi chưa thích) và tăng bộ đếm để `HeartBurst` phát hiệu ứng.
2. `HomePage` chạy thao tác qua `_guard`, gọi `PlaceController.toggleFavorite`; controller đổi trạng thái và `notifyListeners()`.
3. `ListenableBuilder` dựng lại danh sách của tab và huy hiệu đếm ở thanh điều hướng.
4. Khi vuốt, vị trí kéo (`_dragDx`) chỉ là **trạng thái cục bộ** của thẻ, không đi qua controller. Chỉ khi vuốt đủ ngưỡng và thẻ đã thu gọn xong, thẻ mới gọi `onSwipeAway` để `HomePage` ẩn địa điểm (hoặc bỏ thích) rồi hiện SnackBar Hoàn tác.
5. Nếu id địa điểm không tồn tại, controller ném `PlaceNotFoundException` và `_guard` hiển thị thông báo thay vì làm ứng dụng dừng.

Lệnh đi **lên** (widget → controller), trạng thái đi **xuống** (controller → widget).

### Cơ chế animation

Hai nhóm hiệu ứng, chọn theo mức độ điều khiển cần thiết:

| Nhóm | Dùng khi | Trong dự án |
|---|---|---|
| **Implicit** (`AnimatedContainer`, `AnimatedCrossFade`, `AnimatedSwitcher`, `AnimatedRotation`, `AnimatedSize`) | Chỉ cần đổi giá trị thuộc tính, framework tự nội suy | Mở rộng thẻ, đổi icon tim, đổi tab, đổi số trên huy hiệu, thu gọn thẻ sau khi vuốt |
| **Explicit** (`AnimationController` + `Tween`) | Cần dừng, đảo ngược hoặc nối với cử chỉ | Thẻ nảy về hoặc trượt đi khi vuốt, trái tim bật lên khi chạm đúp |

```dart
// Thẻ nảy về chỗ cũ hoặc trượt đi: cùng một controller, đổi đích và đường cong
_slide = Tween<double>(begin: _dragDx, end: target)
    .chain(CurveTween(curve: curve))
    .animate(_controller);

// Chạy animation và xử lý ngoại lệ tập trung
Future<bool> runAnimationSafely(TickerFuture Function() start) async {
  try {
    await start().orCancel;
    return true;
  } on TickerCanceled {
    return false; // bị dừng hoặc dispose: không phải lỗi
  } on Object catch (error) {
    throw AnimationException('Không thể chạy animation.', cause: error);
  }
}
```

### Hằng số chuyển động

- **Thời lượng:** `fast` 200 ms, `normal` 300 ms, `slow` 500 ms. Ngắn đủ để không bắt người dùng chờ.
- **Đường cong:** `defaultCurve` (easeInOut), `settleCurve` (easeOutBack, tạo cảm giác nảy về), `slideAwayCurve` (easeIn, thẻ tăng tốc khi rời đi).
- **Ngưỡng vuốt:** `dismissThreshold` = 100 px.

## 5. Cấu trúc thư mục

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   └── animation_constants.dart
│   ├── errors/
│   │   └── animation_exception.dart
│   └── utils/
│       ├── motion_context.dart
│       └── safe_animation.dart
└── features/
    └── places/
        ├── data/mock_places.dart
        ├── domain/
        │   ├── entities/place.dart
        │   └── errors/place_not_found_exception.dart
        └── presentation/
            ├── controllers/place_controller.dart
            ├── pages/home_page.dart
            └── widgets/
                ├── favorite_badge_icon.dart
                ├── heart_burst.dart
                ├── place_card.dart
                └── place_list_view.dart
```

## 6. Cách kích hoạt hiệu ứng

| Thao tác | Vị trí | Hiệu ứng | Loại |
|---|---|---|---|
| Chạm phần thông tin | Thẻ địa điểm | Chiều cao, bóng đổ và bo góc đổi; mô tả rút gọn chuyển sang đầy đủ; mũi tên xoay | Implicit |
| Chạm đúp vào ảnh | Thẻ địa điểm | Trái tim lớn phóng to rồi mờ dần (`ScaleTransition`, `FadeTransition`) | Explicit |
| Chạm nút tim | Góc ảnh | Icon tim phóng to khi đổi trạng thái | Implicit |
| Vuốt ngang | Thẻ địa điểm | Thẻ bám theo ngón tay, icon hiện dần phía sau; buông tay thì nảy về hoặc trượt đi rồi thu gọn | Explicit + gesture |
| Chuyển tab | Thanh điều hướng | Nội dung mờ dần kèm trượt nhẹ | Implicit |
| Thích hoặc bỏ thích | Thanh điều hướng | Con số trên huy hiệu phóng to khi đổi | Implicit |

## 7. Bảo đảm chuyển động không cản trở thao tác

| Nguyên tắc | Cách thực hiện trong code |
|---|---|
| **Đang kéo thì phản hồi tức thời** | Trong lúc kéo, thẻ chỉ cập nhật vị trí theo ngón tay, không chạy animation. Animation chỉ chạy sau khi buông tay. |
| **Không tranh với cuộn dọc** | Thẻ chỉ lắng nghe kéo **ngang** (`onHorizontalDrag...`), không dùng `onPan`, nên cuộn danh sách vẫn mượt. |
| **Người dùng luôn giành lại quyền điều khiển** | Chạm vào thẻ đang nảy về sẽ gọi `_controller.stop()`; riêng thẻ đang trượt đi thì khóa thao tác để tránh trạng thái nửa vời. |
| **Hiệu ứng không chặn sự kiện** | `HeartBurst` bọc trong `IgnorePointer`, nên không che nút hay vùng chạm bên dưới. |
| **Không chồng hiệu ứng** | Trái tim chỉ phát lại mỗi lần đếm tăng; chạm đúp vào thẻ đã thích chỉ phát hiệu ứng, không bỏ thích. |
| **Ngắn và nhất quán** | Mọi thời lượng đến từ `AnimationConstants`, trong khoảng 200–500 ms. |
| **Có đường lùi** | Mọi hành động vuốt đều có nút **Hoàn tác** trên SnackBar. |
| **Tôn trọng cài đặt hệ thống** | `MotionContext.motionDuration` trả về `Duration.zero` khi người dùng bật Giảm chuyển động. |
| **Không rò rỉ tài nguyên** | Mỗi `AnimationController` được `dispose()` trong `dispose()` của `State`; listener được gỡ trước. |

Cách kiểm tra bằng tìm kiếm trong mã nguồn (PowerShell, chạy ở thư mục gốc dự án):

```powershell
# 1. Không dùng onPan: kết quả rỗng
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern "onPan"

# 2. Thời lượng chỉ khai báo ở một nơi: chỉ có animation_constants.dart
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern "Duration\(milliseconds"

# 3. Mỗi AnimationController (place_card, heart_burst) đều có dispose tương ứng
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern "AnimationController\(","\.dispose\(\)"
```

Trong VS Code: `Ctrl+Shift+F`, tìm `onPan` hoặc `Duration(milliseconds` trong thư mục `lib`.

## 8. Xử lý ngoại lệ

| Tình huống | Nơi phát sinh | Cách xử lý |
|---|---|---|
| Animation bị dừng hoặc `dispose` giữa chừng | `TickerCanceled` từ `forward().orCancel` | `runAnimationSafely` trả `false`, coi là bình thường, không báo lỗi. |
| Lỗi animation không mong đợi | Bất kỳ lỗi nào khác khi chạy animation | Gói thành `AnimationException`; widget đặt thẻ về vị trí gốc và gọi `onAnimationError`, `HomePage` hiện thông báo, ứng dụng vẫn chạy. |
| Địa điểm không tồn tại | `PlaceController` | Ném `PlaceNotFoundException`; `HomePage._guard` bắt và hiện thông báo. |
| `State` đã bị gỡ khi đang chờ animation | Sau mỗi `await` | Kiểm tra `mounted` trước khi `setState` hoặc dùng `context`. |
| Lỗi trong framework (build, layout, paint) | Toàn ứng dụng | `FlutterError.onError` ghi nhận trong `main.dart`. |
| Lỗi bất đồng bộ không có `try/catch` | Toàn ứng dụng | `runZonedGuarded` ghi nhận trong `main.dart`. |

## 9. Hướng dẫn chạy

Yêu cầu: Flutter SDK (Dart `^3.5.0`).

```bash
git clone <đường-dẫn-repo>
cd <thư-mục-dự-án>
flutter pub get
flutter analyze
flutter run -d chrome
```

Nếu thư mục dự án chưa có các thư mục nền tảng (`windows/`, `web/`, `android/`), chạy thêm `flutter create . --project-name animation_gesture_demo --platforms=windows,web,android`. Nếu lệnh này sinh ra file `test/widget_test.dart` mặc định thì xóa file đó, vì nó tham chiếu một widget không có trong dự án.

Để thử các tương tác trên máy tính: dùng chuột nhấn giữ và kéo ngang trên thẻ để vuốt, nhấp đúp vào ảnh để thích. Để thử chế độ giảm chuyển động, bật tùy chọn tương ứng trong cài đặt trợ năng của hệ điều hành rồi chạy lại ứng dụng.

## 10. Công nghệ sử dụng

| Thư viện | Phiên bản | Vai trò |
|---|---|---|
| `flutter` | SDK | Framework giao diện và hệ thống animation |
| `flutter_test` | SDK | Bộ công cụ kiểm thử (dự phòng cho test về sau) |
| `flutter_lints` | ^4.0.0 | Quy tắc phân tích tĩnh |

`ChangeNotifier`, `ListenableBuilder`, `AnimationController` và các widget animation đều có sẵn trong Flutter nên không cần thư viện bên ngoài. `analysis_options.yaml` bật thêm các luật `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `prefer_final_locals`, `always_use_package_imports`, `avoid_print`, `unawaited_futures`, `require_trailing_commas`.

## 11. Hạn chế và hướng phát triển

**Hạn chế:**

- Trạng thái yêu thích và ẩn chỉ lưu trong bộ nhớ, thoát ứng dụng là mất.
- Dữ liệu là danh sách mẫu cục bộ; ảnh minh họa dùng gradient và emoji thay cho ảnh thật.
- `PlaceController` được tạo trong `HomePage`, chưa có cơ chế Dependency Injection.
- Chưa có unit test cho `PlaceController` và widget test cho các hiệu ứng.
- Chuỗi tiếng Việt viết trực tiếp trong code, chưa hỗ trợ đa ngôn ngữ.
- Chưa kiểm thử với trình đọc màn hình thật (TalkBack, VoiceOver) và trên nhiều kích thước thiết bị.

**Hướng phát triển:**

- Lưu trạng thái bền vững bằng `shared_preferences`.
- Dùng `SpringSimulation` cho chuyển động nảy về, và `Hero` cho chuyển cảnh sang trang chi tiết.
- Viết unit test cho `PlaceController` (thích, ẩn, hoàn tác, id không tồn tại) và widget test cho vuốt và chạm đúp.
- Thêm đa ngôn ngữ với `flutter_localizations`.
- Dùng `Provider` hoặc `Riverpod` để cấp controller cho cây widget.

## 12. Phân công công việc (WBS)

| Vai trò | Người phụ trách | File chính |
|---|---|---|
| Cấu hình, tầng lõi | Phạm Viết Duy | `pubspec.yaml`, `analysis_options.yaml`, `core/` |
| Domain, data, controller | Phạm Viết Duy | `features/places/domain/`, `features/places/data/`, `presentation/controllers/` |
| Giao diện, hiệu ứng | Cao Minh Phụng | `presentation/widgets/`, `presentation/pages/`, `main.dart`, `app.dart` |
| Xử lý ngoại lệ | Cả hai | `core/errors/`, `core/utils/safe_animation.dart`, các khối `try/catch` trong widget |
| Báo cáo, slide | Cả hai (Duy viết README, Phụng dàn ý slide) | `README.md`, file slide |
| Tích hợp | Cả hai | Review chéo Pull Request, chạy `flutter analyze` và `flutter run` |

Quy trình Git: Duy làm trên nhánh `feature/core-domain`, Phụng làm trên nhánh `feature/presentation`; mỗi nhánh được người còn lại review rồi merge vào `main`.

## 13. Tài liệu tham khảo

- Flutter, *Introduction to animations* — https://docs.flutter.dev/ui/animations
- Flutter, *Implicit animations* — https://docs.flutter.dev/ui/animations/implicit-animations
- Flutter, *Gestures* — https://docs.flutter.dev/ui/interactivity/gestures
- Flutter API: `AnimationController`, `TweenSequence`, `AnimatedContainer`, `ListenableBuilder` — https://api.flutter.dev
- Material Design 3, *Motion* — https://m3.material.io/styles/motion/overview
- W3C, *WCAG 2.1 – Animation from Interactions* — https://www.w3.org/TR/WCAG21/#animation-from-interactions
- Dart, *Effective Dart: Style* — https://dart.dev/effective-dart/style
