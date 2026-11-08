import 'package:animation_gesture_demo/features/places/domain/entities/place.dart';
import 'package:animation_gesture_demo/features/places/domain/errors/place_not_found_exception.dart';
import 'package:flutter/foundation.dart';

/// Quản lý trạng thái danh sách địa điểm: yêu thích và ẩn.
class PlaceController extends ChangeNotifier {
  PlaceController({required List<Place> places})
      : _allPlaces = List<Place>.unmodifiable(places);

  final List<Place> _allPlaces;
  final Set<String> _favoriteIds = <String>{};
  final Set<String> _hiddenIds = <String>{};

  /// Các địa điểm chưa bị ẩn.
  List<Place> get visiblePlaces => _allPlaces
      .where((place) => !_hiddenIds.contains(place.id))
      .toList(growable: false);

  /// Các địa điểm đang hiển thị và được yêu thích.
  List<Place> get favoritePlaces => visiblePlaces
      .where((place) => _favoriteIds.contains(place.id))
      .toList(growable: false);

  int get favoriteCount => favoritePlaces.length;

  bool get hasHiddenPlaces => _hiddenIds.isNotEmpty;

  bool isFavorite(String placeId) => _favoriteIds.contains(placeId);

  /// Đảo trạng thái yêu thích.
  ///
  /// Ném [PlaceNotFoundException] nếu [placeId] không tồn tại.
  void toggleFavorite(String placeId) =>
      setFavorite(placeId, value: !isFavorite(placeId));

  void setFavorite(String placeId, {required bool value}) {
    _ensureExists(placeId);
    final changed =
        value ? _favoriteIds.add(placeId) : _favoriteIds.remove(placeId);
    if (changed) notifyListeners();
  }

  void hidePlace(String placeId) {
    _ensureExists(placeId);
    if (_hiddenIds.add(placeId)) notifyListeners();
  }

  void restorePlace(String placeId) {
    _ensureExists(placeId);
    if (_hiddenIds.remove(placeId)) notifyListeners();
  }

  void restoreAll() {
    if (_hiddenIds.isEmpty) return;
    _hiddenIds.clear();
    notifyListeners();
  }

  void _ensureExists(String placeId) {
    if (!_allPlaces.any((place) => place.id == placeId)) {
      throw PlaceNotFoundException(placeId);
    }
  }
}
