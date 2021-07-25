import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:src/env/env.dart';

const int limit = 10;
const String type = 'city';

Future<List<Places>> search(String input) async {
  List<Places> results = [];
  final response = await http.get(Uri.parse(
      'https://api.geoapify.com/v1/geocode/autocomplete?text=' +
          input +
          '&limit=' +
          limit.toString() +
          '&type=' +
          type +
          '&apiKey=' +
          Env.geoapify));
  if (response.statusCode == 200) {
    dynamic data = jsonDecode(response.body);
    for (int i = 0; i < data['features'].length; i++) {
      results.add(Places(
          name: data['features'][i]['properties']['formatted'],
          lat: data['features'][i]['geometry']['coordinates'][0],
          long: data['features'][i]['geometry']['coordinates'][1]));
    }
    return results;
  } else {
    return results;
  }
}

class Search {
  Search();

  List<Places> results = [];

  void lookUp(String input) async {
    results = [];
    final response = await http.get(Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=' +
            input +
            '&limit=' +
            limit.toString() +
            '&type=' +
            type +
            '&apiKey=' +
            Env.geoapify));
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      for (int i = 0; i < data['features'].length; i++) {
        results.add(Places(
            name: data['features'][i]['properties']['formatted'],
            lat: data['features'][i]['geometry']['coordinates'][0],
            long: data['features'][i]['geometry']['coordinates'][1]));
      }
    }
  }
}

class Places {
  String name;
  double lat;
  double long;

  Places({required this.name, required this.lat, required this.long});
}
