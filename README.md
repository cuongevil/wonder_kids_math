# 📚 Wonder Kids Math – Hành Trình Toán lớp 1

Ứng dụng Flutter giúp bé học toán lớp 1 theo lộ trình game hóa 🎮.  
Mỗi chủ đề được thiết kế như một **level** trên bản đồ, bé phải vượt qua lần lượt để mở khóa thử thách tiếp theo.

---

## 🚀 Tính năng chính

- **Map dọc/ngang** với các chặng: số, cộng/trừ, so sánh, hình học, đo lường, boss cuối.
- **Mini-games** cho từng chủ đề:
    - Học số 0–10, 11–20 (flashcard + audio).
    - Phép cộng/trừ ≤10 và ≤20.
    - So sánh số.
    - Nhận diện hình học cơ bản.
    - Đo lường và thời gian (so sánh, đồng hồ, lịch).
    - Boss cuối 🏰🐉 tổng hợp thử thách trong 60 giây.
- **Progress tracking**: level hoàn thành → mở khóa level tiếp theo.
- **Hiệu ứng glow** khi hoàn thành level.

---

## 📂 Cấu trúc thư mục
lib/
├── main.dart
├── models/
│ └── level.dart
├── services/
│ └── progress_service.dart
├── widgets/
│ ├── glow_ring.dart
│ └── level_node.dart
└── screens/
├── map_screen.dart
├── level_detail.dart
├── learn_numbers.dart
├── learn_numbers_20.dart
├── game_addition10.dart
├── game_subtraction10.dart
├── game_compare.dart
├── game_addition20.dart
├── game_subtraction20.dart
├── game_shapes.dart
├── game_measure_time.dart
└── game_final_boss.dart