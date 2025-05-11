class Puzzle {
  Puzzle({required this.correctPieceRect, required this.fakePieces});
  late final CorrectPieceRect correctPieceRect;
  late final List<FakePieces> fakePieces;

  Puzzle.fromJson(Map<String, dynamic> json) {
    correctPieceRect = CorrectPieceRect.fromJson(json['correctPieceRect']);
    fakePieces =
        List.from(
          json['fakePieces'],
        ).map((e) => FakePieces.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['correctPieceRect'] = correctPieceRect.toJson();
    _data['fakePieces'] = fakePieces.map((e) => e.toJson()).toList();
    return _data;
  }
}

class CorrectPieceRect {
  CorrectPieceRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  late final int x;
  late final int y;
  late final int width;
  late final int height;

  CorrectPieceRect.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['x'] = x;
    _data['y'] = y;
    _data['width'] = width;
    _data['height'] = height;
    return _data;
  }
}

class FakePieces {
  FakePieces({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  late final int x;
  late final int y;
  late final int width;
  late final int height;

  FakePieces.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['x'] = x;
    _data['y'] = y;
    _data['width'] = width;
    _data['height'] = height;
    return _data;
  }
}
