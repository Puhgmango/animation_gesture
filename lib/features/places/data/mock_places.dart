import 'package:animation_gesture_demo/features/places/domain/entities/place.dart';

/// Dữ liệu mẫu cục bộ (không cần mạng).
const List<Place> mockPlaces = <Place>[
  Place(
    id: 'hoi-an',
    name: 'Phố cổ Hội An',
    location: 'Quảng Nam',
    description: 'Những dãy nhà cổ vàng, đèn lồng rực rỡ về đêm và ẩm thực '
        'đường phố nổi tiếng như cao lầu, mì Quảng, bánh mì Phượng.',
    emoji: '🏮',
    rating: 4.8,
    gradientStart: 0xFFFFB74D,
    gradientEnd: 0xFFE57373,
  ),
  Place(
    id: 'da-lat',
    name: 'Đà Lạt',
    location: 'Lâm Đồng',
    description: 'Thành phố ngàn hoa với khí hậu mát mẻ quanh năm, đồi thông, '
        'hồ Xuân Hương và những quán cà phê view núi.',
    emoji: '🌲',
    rating: 4.7,
    gradientStart: 0xFF81C784,
    gradientEnd: 0xFF4DB6AC,
  ),
  Place(
    id: 'ha-long',
    name: 'Vịnh Hạ Long',
    location: 'Quảng Ninh',
    description: 'Di sản thiên nhiên thế giới với hàng nghìn đảo đá vôi, '
        'thích hợp đi du thuyền, chèo kayak và ngủ đêm trên vịnh.',
    emoji: '⛵',
    rating: 4.9,
    gradientStart: 0xFF4FC3F7,
    gradientEnd: 0xFF3F51B5,
  ),
  Place(
    id: 'sa-pa',
    name: 'Sa Pa',
    location: 'Lào Cai',
    description: 'Ruộng bậc thang uốn lượn, núi Fansipan hùng vĩ và nét văn '
        'hoá đặc sắc của các dân tộc vùng cao.',
    emoji: '⛰️',
    rating: 4.6,
    gradientStart: 0xFFA5D6A7,
    gradientEnd: 0xFF607D8B,
  ),
  Place(
    id: 'phu-quoc',
    name: 'Phú Quốc',
    location: 'Kiên Giang',
    description: 'Đảo ngọc với bãi biển cát trắng, nước trong xanh, '
        'lặn ngắm san hô và hoàng hôn tuyệt đẹp ở Sunset Town.',
    emoji: '🏝️',
    rating: 4.7,
    gradientStart: 0xFF80DEEA,
    gradientEnd: 0xFFFFCC80,
  ),
  Place(
    id: 'hue',
    name: 'Cố đô Huế',
    location: 'Thừa Thiên Huế',
    description: 'Quần thể di tích Đại Nội, lăng tẩm các vua triều Nguyễn, '
        'sông Hương thơ mộng và ẩm thực cung đình.',
    emoji: '🏯',
    rating: 4.5,
    gradientStart: 0xFFCE93D8,
    gradientEnd: 0xFF7986CB,
  ),
];
