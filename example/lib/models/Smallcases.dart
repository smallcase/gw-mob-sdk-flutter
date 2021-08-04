
class Smallcases {

  //TODO: change dynamic to HoldingsDataWrapper
  final List<dynamic> private;

  //TODO: change dynamic to HoldingsDataWrapper
  final List<dynamic> public;

  Smallcases({
    this.private,
    this.public
});

  factory Smallcases.fromJson(Map<String, dynamic> parsedJson) {

    var private = parsedJson['private'];

    var public = parsedJson['public'];

    return Smallcases(
      private: private,
      public: public
    );
  }
}