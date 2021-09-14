
import 'package:scgateway_flutter_plugin_example/models/Private.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcaseHoldingDTO.dart';

class Smallcases {

  final List<Private> private;
  // final Private private;

  final List<SmallcaseHoldingDTO> public;

  Smallcases({
    this.private,
    this.public
});

  factory Smallcases.fromJson(Map<dynamic, dynamic> parsedJson) {

    var publicJson = parsedJson['public'] as List;
    List<SmallcaseHoldingDTO> public = publicJson.map((i) => SmallcaseHoldingDTO.fromJson(i)).toList();

    // var private = Private.fromJson(parsedJson['private']);
    var privateJson = parsedJson['private'] as List;
    // List<Private> private = privateJson.map((i) => Private.fromJson(i)).toList();
    List<Private> private = privateJson.map((e) => Private.fromJson(e)).toList();

    return Smallcases(
      private: private,
      public: public
    );
  }
}