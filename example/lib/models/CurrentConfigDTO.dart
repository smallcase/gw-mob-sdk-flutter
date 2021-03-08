
import 'ConstituentsDTO.dart';

class CurrentConfigDTO {

  final List<ConstituentsDTO> constituents;

  CurrentConfigDTO({this.constituents});

  factory CurrentConfigDTO.fromJson(Map<String, dynamic> parsedJson) {

    var constituentsFromJson = parsedJson['constituents'] as List;
    List<ConstituentsDTO> constituentsList = constituentsFromJson.map((i) => ConstituentsDTO.fromJson(i)).toList();

    return CurrentConfigDTO(
      constituents: constituentsList
    );

  }

}