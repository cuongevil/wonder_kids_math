enum LevelType { start, topic, boss, end }
enum LevelState { locked, playable, completed }

class Level {
  final int index;
  final String title;
  final String? route;
  final LevelType type;
  LevelState state;
  final String? levelKey;
  int stars;
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

  /// ✅ Convert → JSON (enum dưới dạng raw value)
  Map<String, dynamic> toJson() => {
    'index': index,
    'title': title,
    'route': route,
    'type': type.name, // 👈 chỉ lưu "start" / "topic" / "boss" / "end"
    'state': state.name, // 👈 chỉ lưu "locked" / "playable" / "completed"
    'levelKey': levelKey,
    'stars': stars,
    'total': total,
  };

  /// ✅ Convert JSON → object
  factory Level.fromJson(Map<String, dynamic> json) {
    LevelType parseType(String? v) {
      return LevelType.values.firstWhere(
            (e) => e.name == v,
        orElse: () => LevelType.topic,
      );
    }

    LevelState parseState(String? v) {
      return LevelState.values.firstWhere(
            (e) => e.name == v,
        orElse: () => LevelState.locked,
      );
    }

    return Level(
      index: json['index'] ?? 0,
      title: json['title'] ?? '',
      route: json['route'],
      type: parseType(json['type']),
      state: parseState(json['state']),
      levelKey: json['levelKey'],
      stars: json['stars'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
