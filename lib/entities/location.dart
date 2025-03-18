import 'package:oservice/entities/coordinates.dart';

class Location {
  late String id;
  final Coordinates coordinates;
  final String address;
  final String city;
  final String title;
  final String href;

  Location({required this.coordinates, required this.address, required this.city, required this.title, required this.href});

  Location.fromMap(Map<String, dynamic> data) :
    coordinates = Coordinates.fromMap(data['coordinates']),
    address = data['address'],
    city = data['city'],
    title = data['title'],
    href = data['href'];

  toMap() {
    return {
      'coordinates': coordinates.toMap(),
      'address': address,
      'city': city,
      'title': title,
      'href': href,
    };
  }


  @override
  String toString() {
    return "$title - con id: $id";
  }

  String getCoordinateString() {
    return "${coordinates.latitude}, ${coordinates.longitude}";
  }
}