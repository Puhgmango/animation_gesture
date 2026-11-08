/// Ném ra khi thao tác trên một địa điểm không tồn tại.
class PlaceNotFoundException implements Exception {
  const PlaceNotFoundException(this.placeId);

  final String placeId;

  @override
  String toString() => 'PlaceNotFoundException: không tìm thấy "$placeId"';
}
