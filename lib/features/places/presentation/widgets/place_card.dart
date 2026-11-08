import 'package:animation_gesture_demo/core/constants/animation_constants.dart';
import 'package:animation_gesture_demo/core/errors/animation_exception.dart';
import 'package:animation_gesture_demo/core/utils/motion_context.dart';
import 'package:animation_gesture_demo/core/utils/safe_animation.dart';
import 'package:animation_gesture_demo/features/places/domain/entities/place.dart';
import 'package:animation_gesture_demo/features/places/presentation/widgets/heart_burst.dart';
import 'package:flutter/material.dart';

/// Thẻ địa điểm với ba tương tác:
/// - Chạm đúp vào ảnh: thích (trái tim bật lên).
/// - Chạm vào phần thông tin: mở rộng / thu gọn (implicit animation).
/// - Vuốt ngang: thực hiện hành động (explicit animation + gesture).
class PlaceCard extends StatefulWidget {
  const PlaceCard({
    required this.place,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onSwipeAway,
    required this.swipeIcon,
    this.onAnimationError,
    super.key,
  });

  final Place place;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  /// Gọi sau khi thẻ đã trượt đi và thu gọn xong.
  final ValueChanged<Place> onSwipeAway;
  final IconData swipeIcon;
  final ValueChanged<AnimationException>? onAnimationError;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard>
    with SingleTickerProviderStateMixin {
  static const double _radius = 20;

  late final AnimationController _controller;
  Animation<double>? _slide;
  double _dragDx = 0;
  bool _isExpanded = false;
  bool _isRemoving = false;
  bool _isCollapsed = false;
  int _heartTrigger = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.normal,
    )..addListener(_onTick);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  void _onTick() {
    final slide = _slide;
    if (slide == null || !mounted) return;
    setState(() => _dragDx = slide.value);
  }

  // ---------------------------------------------------------------- Gestures

  void _onDragStart(DragStartDetails details) {
    if (_isRemoving) return;
    // Người dùng chạm lại: dừng animation đang chạy, trả quyền điều khiển.
    if (_controller.isAnimating) _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isRemoving) return;
    setState(() => _dragDx += details.delta.dx);
  }

  Future<void> _onDragEnd([DragEndDetails? details]) async {
    if (_isRemoving) return;
    if (_dragDx.abs() >= AnimationConstants.dismissThreshold) {
      await _slideAway();
    } else {
      await _animateTo(0, curve: AnimationConstants.settleCurve);
    }
  }

  void _onDoubleTap() {
    if (!widget.isFavorite) widget.onToggleFavorite();
    setState(() => _heartTrigger++);
  }

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  // -------------------------------------------------------------- Animations

  /// Trả về `true` nếu animation chạy xong.
  Future<bool> _animateTo(double target, {required Curve curve}) async {
    if (context.isMotionReduced) {
      setState(() => _dragDx = target);
      return true;
    }
    _slide = Tween<double>(begin: _dragDx, end: target)
        .chain(CurveTween(curve: curve))
        .animate(_controller);
    try {
      return await runAnimationSafely(() => _controller.forward(from: 0));
    } on AnimationException catch (error) {
      if (!mounted) return false;
      setState(() => _dragDx = 0);
      widget.onAnimationError?.call(error);
      return false;
    }
  }

  Future<void> _slideAway() async {
    _isRemoving = true;
    final width = context.size?.width ?? MediaQuery.sizeOf(context).width;
    final direction = _dragDx.isNegative ? -1 : 1;

    final completed = await _animateTo(
      direction * (width + 40),
      curve: AnimationConstants.slideAwayCurve,
    );
    if (!mounted) return;
    if (!completed) {
      _isRemoving = false;
      return;
    }

    // Thu gọn chiều cao để các thẻ bên dưới trượt lên mượt mà.
    setState(() => _isCollapsed = true);
    await Future<void>.delayed(
      context.motionDuration(AnimationConstants.normal),
    );
    if (mounted) widget.onSwipeAway(widget.place);
  }

  // ------------------------------------------------------------------- Build

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final duration = context.motionDuration(AnimationConstants.normal);

    return AnimatedSize(
      duration: duration,
      curve: AnimationConstants.defaultCurve,
      alignment: Alignment.topCenter,
      child: _isCollapsed
          ? const SizedBox(width: double.infinity, height: 0)
          : Padding(
              padding: const EdgeInsets.only(bottom: 16),
              // Chỉ lắng nghe kéo NGANG để không cản việc cuộn dọc danh sách.
              child: GestureDetector(
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                onHorizontalDragCancel: _onDragEnd,
                child: Stack(
                  children: [
                    if (_dragDx != 0) _buildSwipeBackground(colors),
                    Transform.translate(
                      offset: Offset(_dragDx, 0),
                      child: _buildCard(colors, duration),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSwipeBackground(ColorScheme colors) {
    final progress = (_dragDx.abs() / AnimationConstants.dismissThreshold)
        .clamp(0.0, 1.0)
        .toDouble();

    return Positioned.fill(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: _dragDx >= 0 ? Alignment.centerLeft : Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Opacity(
          opacity: progress,
          child: Icon(
            widget.swipeIcon,
            size: 28 + 8 * progress,
            color: colors.onTertiaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ColorScheme colors, Duration duration) {
    return AnimatedContainer(
      duration: duration,
      curve: AnimationConstants.defaultCurve,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withAlpha(_isExpanded ? 70 : 30),
            blurRadius: _isExpanded ? 24 : 8,
            offset: Offset(0, _isExpanded ? 10 : 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(colors, duration),
          _buildInfo(colors, duration),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors, Duration duration) {
    final place = widget.place;

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(place.gradientStart), Color(place.gradientEnd)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(place.emoji, style: const TextStyle(fontSize: 64)),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                tooltip: widget.isFavorite ? 'Bỏ thích' : 'Thích',
                onPressed: widget.onToggleFavorite,
                icon: AnimatedSwitcher(
                  duration: duration,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey<bool>(widget.isFavorite),
                    color: widget.isFavorite ? colors.error : null,
                  ),
                ),
              ),
            ),
            HeartBurst(trigger: _heartTrigger),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(ColorScheme colors, Duration duration) {
    final place = widget.place;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleExpanded,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: colors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(place.location, style: textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(place.rating.toStringAsFixed(1)),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: duration,
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: duration,
              sizeCurve: AnimationConstants.defaultCurve,
              alignment: Alignment.topLeft,
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                place.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(place.description),
            ),
          ],
        ),
      ),
    );
  }
}
