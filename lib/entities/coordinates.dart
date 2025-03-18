import 'package:http/http.dart' as http;
import 'dart:convert';

class Coordinates {
  final String latitude;
  final String longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'Coordinates: {latitude: $latitude, longitude: $longitude}';
  }

  Future<Map<String, String>> reverseGeocoding() async {
    double latitude = double.parse(this.latitude);
    double longitude = double.parse(this.longitude);

    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept-language': 'it', // Imposta la lingua della risposta in Italiano
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address']?['road'];
        final city = data['address']?['city'] ?? data['address']?['town'] ?? data['address']?['village'];
        return {
          "address": address,
          "city": city,
        };
      } else {
        print('Errore durante il recupero dei dettagli: ${response.statusCode}');
        throw Exception('Errore durante il recupero dei dettagli');
      }
    } catch (e) {
      print('Errore durante la richiesta: $e');
      throw Exception('Errore durante la richiesta');
    }
  }

}