enum LevelState { locked, playable, completed }
enum LevelType { start, topic, boss, end }

class Level {
  final int index;        // số thứ tự level
  final String title;     // tiêu đề hiển thị
  final LevelType type;   // loại level (start, topic, boss, end)
  LevelState state;       // trạng thái (locked, playable, completed)
  double? progress;       // tiến độ (0.0 -> 1.0)
  final String? route;    // route để mở màn hình game

  Level({
    required this.index,
    required this.title,
    required this.type,
    required this.state,
    this.progress,
    this.route,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'title': title,
    'type': type.index,
    'state': state.index,
    'progress': progress,
    'route': route,
  };

  static Level fromJson(Map<String, dynamic> j) => Level(
    index: j['index'],
    title: j['title'],
    type: LevelType.values[j['type']],
    state: LevelState.values[j['state']],
    progress: (j['progress'] as num?)?.toDouble(),
    route: j['route'],
  );
}
