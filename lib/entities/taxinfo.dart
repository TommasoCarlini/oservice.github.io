class TaxInfo {
  late String id;
  final String name;
  final String surname;
  final String address;
  final String zipCode;
  final String city;
  final String birthDate;
  final String birthPlace;
  final String gender;
  final String collaboratorId;
  final String fiscalCode;

  TaxInfo({
    required this.name,
    required this.surname,
    required this.address,
    required this.zipCode,
    required this.city,
    required this.birthDate,
    required this.birthPlace,
    required this.gender,
    required this.collaboratorId,
    required this.fiscalCode,
  });

  factory TaxInfo.fromMap(Map<String, dynamic> data) {
    return TaxInfo(
        name: data['name'],
        surname: data['surname'],
        address: data['address'],
        zipCode: data['zipCode'],
        city: data['city'],
        birthDate: data['birthDate'],
        birthPlace: data['birthPlace'],
        gender: data['gender'],
        collaboratorId: data['collaboratorId'],
        fiscalCode: data['fiscalCode']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'address': address,
      'zipCode': zipCode,
      'city': city,
      'birthDate': birthDate,
      'birthPlace': birthPlace,
      'gender': gender,
      'collaboratorId': collaboratorId,
      'fiscalCode': fiscalCode,
    };
  }
}
