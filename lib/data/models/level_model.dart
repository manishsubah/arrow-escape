/// Raw JSON-mapped model for an arrow within a level definition.
class ArrowModel {
  const ArrowModel({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.length = 1,
    required this.colorIndex,
  });

  final int id;
  final int row;
  final int col;
  final String direction; // "up", "down", "left", "right"
  final int length;
  final int colorIndex;

  factory ArrowModel.fromJson(Map<String, dynamic> json) {
    return ArrowModel(
      id: json['id'] as int,
      row: json['row'] as int,
      col: json['col'] as int,
      direction: json['direction'] as String,
      length: (json['length'] as int?) ?? 1,
      colorIndex: json['colorIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'row': row,
    'col': col,
    'direction': direction,
    'length': length,
    'colorIndex': colorIndex,
  };
}

/// Raw JSON-mapped model for a level definition.
class LevelModel {
  const LevelModel({
    required this.id,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.solution,
  });

  final int id;
  final int rows;
  final int cols;
  final List<ArrowModel> arrows;
  final List<int> solution;

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as int,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      arrows: (json['arrows'] as List<dynamic>)
          .map((a) => ArrowModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      solution: (json['solution'] as List<dynamic>)
          .map((s) => s as int)
          .toList(),
    );
  }
}
