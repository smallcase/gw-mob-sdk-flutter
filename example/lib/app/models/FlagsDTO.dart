
class FlagsDTO {

  final bool? featured;

  FlagsDTO({this.featured});

  factory FlagsDTO.fromJson(Map<String, dynamic> parsedJson) {

    return FlagsDTO(
      featured: parsedJson['featured']
    );
  }

}