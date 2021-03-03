
class PublisherDTO {

  final String publisherId;

  final String name;

  final String logo;

  PublisherDTO({this.publisherId, this.name, this.logo});

  factory PublisherDTO.fromJson(Map<String, dynamic> parsedJson) {

    return PublisherDTO(
      publisherId: parsedJson['publisherId'],
      name: parsedJson['name'],
      logo: parsedJson['logo']
    );

  }

}