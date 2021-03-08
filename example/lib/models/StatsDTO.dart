
class StatsDTO {

  final dynamic indexValue;

  StatsDTO({this.indexValue});

  factory StatsDTO.fromJson(Map<String, dynamic> parsedJson) {

    return StatsDTO(
      indexValue: parsedJson['indexValue']
    );

  }
}