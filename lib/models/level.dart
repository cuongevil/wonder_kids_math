enum LevelType { start, topic, boss, end }
enum LevelState { locked, playable, completed }

class Level {
  final int index;
  final String title;
  final String? route;
  final LevelType type;
  LevelState state;

  /// Key map sang ProgressService (vd: "0_10", "11_20", "addition10")
  final String? levelKey;

  /// Số sao đã học trong level
  int stars;

  /// Tổng số bài trong level
  int total;

  Level({
    required this.index,
    required this.title,
    this.route,
    required this.type,
    this.state = LevelState.locked,
    this.levelKey,
    this.stars = 0,
    this.total = 0,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'title': title,
    'route': route,
    'type': type.toString(),
    'state': state.toString(),
    'levelKey': levelKey,
    'stars': stars,
    'total': total,
  };

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      index: json['index'],
      title: json['title'],
      route: json['route'],
      type: LevelType.values.firstWhere(
            (e) => e.toString() == json['type'],
        orElse: () => LevelType.topic,
      ),
      state: LevelState.values.firstWhere(
            (e) => e.toString() == json['state'],
        orElse: () => LevelState.locked,
      ),
      levelKey: json['levelKey'],
      stars: json['stars'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
