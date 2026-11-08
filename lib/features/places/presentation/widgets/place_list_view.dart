import 'package:animation_gesture_demo/core/errors/animation_exception.dart';
import 'package:animation_gesture_demo/features/places/domain/entities/place.dart';
import 'package:animation_gesture_demo/features/places/presentation/widgets/place_card.dart';
import 'package:flutter/material.dart';

/// Danh sách thẻ địa điểm kèm dòng gợi ý và trạng thái rỗng.
class PlaceListView extends StatelessWidget {
  const PlaceListView({
    required this.places,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onSwipeAway,
    required this.swipeIcon,
    required this.hint,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onAnimationError,
    super.key,
  });

  final List<Place> places;
  final bool Function(String placeId) isFavorite;
  final ValueChanged<Place> onToggleFavorite;
  final ValueChanged<Place> onSwipeAway;
  final IconData swipeIcon;
  final String hint;
  final String emptyTitle;
  final String emptySubtitle;
  final ValueChanged<AnimationException>? onAnimationError;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return _EmptyState(title: emptyTitle, subtitle: emptySubtitle);
    }

    return ListView.builder(
      // Hai tab có thể tồn tại cùng lúc khi chuyển tab,
      // nên không dùng PrimaryScrollController chung.
      primary: false,
      padding: const EdgeInsets.all(16),
      itemCount: places.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _HintBanner(text: hint);

        final place = places[index - 1];
        return PlaceCard(
          key: ValueKey<String>(place.id),
          place: place,
          isFavorite: isFavorite(place.id),
          onToggleFavorite: () => onToggleFavorite(place),
          onSwipeAway: onSwipeAway,
          swipeIcon: swipeIcon,
          onAnimationError: onAnimationError,
        );
      },
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: colors.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
