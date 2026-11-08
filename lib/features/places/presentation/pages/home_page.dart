import 'package:animation_gesture_demo/core/constants/animation_constants.dart';
import 'package:animation_gesture_demo/core/errors/animation_exception.dart';
import 'package:animation_gesture_demo/core/utils/motion_context.dart';
import 'package:animation_gesture_demo/features/places/data/mock_places.dart';
import 'package:animation_gesture_demo/features/places/domain/entities/place.dart';
import 'package:animation_gesture_demo/features/places/domain/errors/place_not_found_exception.dart';
import 'package:animation_gesture_demo/features/places/presentation/controllers/place_controller.dart';
import 'package:animation_gesture_demo/features/places/presentation/widgets/favorite_badge_icon.dart';
import 'package:animation_gesture_demo/features/places/presentation/widgets/place_list_view.dart';
import 'package:flutter/material.dart';

/// Màn hình chính: hai tab "Khám phá" và "Yêu thích".
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PlaceController _controller;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PlaceController(places: mockPlaces);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- Actions

  /// Chạy một thao tác trên controller và bắt lỗi nghiệp vụ.
  void _guard(VoidCallback action) {
    try {
      action();
    } on PlaceNotFoundException catch (error) {
      debugPrint(error.toString());
      _showSnackBar('Không tìm thấy địa điểm này.');
    }
  }

  void _toggleFavorite(Place place) =>
      _guard(() => _controller.toggleFavorite(place.id));

  void _hidePlace(Place place) {
    _guard(() {
      _controller.hidePlace(place.id);
      _showSnackBar(
        'Đã ẩn ${place.name}',
        actionLabel: 'Hoàn tác',
        onAction: () => _guard(() => _controller.restorePlace(place.id)),
      );
    });
  }

  void _unfavoritePlace(Place place) {
    _guard(() {
      _controller.setFavorite(place.id, value: false);
      _showSnackBar(
        'Đã bỏ ${place.name} khỏi yêu thích',
        actionLabel: 'Hoàn tác',
        onAction: () =>
            _guard(() => _controller.setFavorite(place.id, value: true)),
      );
    });
  }

  void _onAnimationError(AnimationException error) {
    debugPrint(error.toString());
    _showSnackBar('Hiệu ứng gặp sự cố, ứng dụng vẫn hoạt động bình thường.');
  }

  void _showSnackBar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }

  // ------------------------------------------------------------------ Build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Du lịch Việt Nam'),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => IconButton(
              tooltip: 'Hiện lại các địa điểm đã ẩn',
              icon: const Icon(Icons.restore),
              onPressed:
                  _controller.hasHiddenPlaces ? _controller.restoreAll : null,
            ),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => AnimatedSwitcher(
              duration: context.motionDuration(AnimationConstants.normal),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _buildTab(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final count = _controller.favoriteCount;
          return NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (index) =>
                setState(() => _tabIndex = index),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Khám phá',
              ),
              NavigationDestination(
                icon: FavoriteBadgeIcon(
                  count: count,
                  icon: Icons.favorite_border,
                ),
                selectedIcon: FavoriteBadgeIcon(
                  count: count,
                  icon: Icons.favorite,
                ),
                label: 'Yêu thích',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab() {
    final isDiscoverTab = _tabIndex == 0;

    return PlaceListView(
      key: ValueKey<int>(_tabIndex),
      places:
          isDiscoverTab ? _controller.visiblePlaces : _controller.favoritePlaces,
      isFavorite: _controller.isFavorite,
      onToggleFavorite: _toggleFavorite,
      onSwipeAway: isDiscoverTab ? _hidePlace : _unfavoritePlace,
      swipeIcon: isDiscoverTab ? Icons.visibility_off_outlined : Icons.heart_broken,
      hint: isDiscoverTab
          ? 'Chạm đúp ảnh để thích · Chạm thông tin để xem thêm · '
              'Vuốt ngang để ẩn'
          : 'Vuốt ngang để bỏ khỏi danh sách yêu thích',
      emptyTitle: isDiscoverTab ? 'Đã ẩn hết địa điểm' : 'Chưa có mục yêu thích',
      emptySubtitle: isDiscoverTab
          ? 'Bấm nút khôi phục ở góc trên để hiện lại.'
          : 'Chạm đúp vào ảnh ở tab Khám phá để thêm vào đây.',
      onAnimationError: _onAnimationError,
    );
  }
}
