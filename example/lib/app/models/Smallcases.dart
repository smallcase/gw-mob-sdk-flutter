import 'package:scgateway_flutter_plugin_example/app/models/Private.dart';
import 'package:scgateway_flutter_plugin_example/app/models/SmallcaseHoldingDTO.dart';

class Smallcases {
  final List<Private>? private;
  // final Private private;

  final List<SmallcaseHoldingDTO>? public;

  Smallcases({this.private, this.public});

  factory Smallcases.fromJson(Map<dynamic, dynamic> parsedJson) {
    var publicJson = parsedJson['public'] as List;
    List<SmallcaseHoldingDTO> public =
        publicJson.map((i) => SmallcaseHoldingDTO.fromJson(i)).toList();

    // var private = Private.fromJson(parsedJson['private']);
    var privateJson = parsedJson['private'] as List;
    // List<Private> private = privateJson.map((i) => Private.fromJson(i)).toList();
    List<Private> private =
        privateJson.map((e) => Private.fromJson(e)).toList();

    return Smallcases(private: private, public: public);
  }
}

class SmallcasesV2 {
  final PrivateV2? privateV2;
  final List<SmallcaseHoldingDTO>? public;

  SmallcasesV2({this.privateV2, this.public});

  factory SmallcasesV2.fromMap(Map<String, dynamic> map) => SmallcasesV2(
    privateV2: PrivateV2.fromMap(map['private']),
    public: (map['public'] as List).map((e) => SmallcaseHoldingDTO.fromJson(e)).toList()
  );

  @override
  String toString() => 'SmallcasesV2(privateV2: $privateV2, public: $public)';
}
