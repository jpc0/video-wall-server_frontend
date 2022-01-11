import 'dart:convert';
import 'dart:collection';

import "package:rxdart/rxdart.dart";
import "package:http/http.dart" as http;

class VideoWallBloc {
  final _imageSubject = BehaviorSubject<UnmodifiableListView<dynamic>>();

  VideoWallBloc() {
    _getAllImages().then((_) {
      _imageSubject.add(UnmodifiableListView(_images));
    });
  }
  Stream<UnmodifiableListView<dynamic>> get images => _imageSubject.stream;

  var _images = [];

  Future<Null> _getAllImages() async {
    var response = await http.get(Uri.parse("http://localhost:5000/get_all"));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (decodedResponse["message"] == "all_files") {
      _images = decodedResponse["content"];
    } else {
      _images = [];
    }
  }
}
