import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class EarthquakeService {
  Future<List<Earthquake>> fetchEarthquakes({int limit = 25, int offset = 1}) async {
    final String apiUrl =
        'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&limit=$limit&offset=$offset&orderby=time';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        return features
            .map((feature) => Earthquake.fromJson(feature))
            .toList();
      } else {
        throw Exception('Failed to load earthquakes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching earthquakes: $e');
    }
  }
}