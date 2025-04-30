import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:puzzle_test/model/puzzle.dart';

class Network {
  //
  static Uri url = Uri.parse(
    'https://681232f03ac96f7119a73cfc.mockapi.io/type',
  );
  //
  static List<Puzzle> puzzles = [];
  //!Get data from the server
  static void getData() async {
    puzzles.clear();
    http.get(Network.url).then((response) {
      if (response.statusCode == 200) {
        List jasonDecode = convert.jsonDecode(response.body);
        for (var puzzle in jasonDecode) {
          puzzles.add(Puzzle.fromJson(puzzle));
        }
        print("jasonDecode: $jasonDecode");
      }
    });
  }

  //* post data to the server
  static void postData({
    required CorrectPieceRect correctPieceRect,
    required List<FakePieces> fakePieces,
  }) async {
    final puzzle = Puzzle(
      correctPieceRect: correctPieceRect,
      fakePieces: fakePieces,
    );

    final response = await http.post(
      Network.url,
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(puzzle.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Data posted successfully");
    } else {
      print("❌ Failed to post data: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }
}
