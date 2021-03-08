
import 'ReturnsDTO.dart';

class ExitedSmallcaseDTO {

  final String iscid;

  final String scid;

  final String name;

  final String date;

  final String dateSold;

  final ReturnsDTO returns;

  ExitedSmallcaseDTO({this.iscid, this.scid, this.name, this.date, this.dateSold, this.returns});

  factory ExitedSmallcaseDTO.fromJson(Map<String, dynamic> parsedJson) {

    return ExitedSmallcaseDTO(
      iscid: parsedJson['iscid'],
      scid: parsedJson['scid'],
      name: parsedJson['name'],
      date: parsedJson['date'],
      dateSold: parsedJson['dateSold'],
      returns: ReturnsDTO.fromJson(parsedJson['returns'])
    );

  }
}