import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:src/search/search.dart';

int maxSavedLocations = 5;

Future<String> _getLocalPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> _getSavedLocations() async {
  final String path = await _getLocalPath();
  return File('$path/locations.json');
}

Future<File> _writeSavedLocations(Map<String, dynamic> value) async {
  final File file = await _getSavedLocations();
  return file.writeAsString(json.encode(value));
}

Future<dynamic> getLocationsJson() async {
  final File file = await _getSavedLocations();
  dynamic result;
  try {
    result = jsonDecode(await file.readAsString());
  } on FileSystemException {
    result = {'locations': []};
    file.writeAsString(json.encode(result));
  }
  return result;
}

Future<List<Places>> getPlaces() async {
  dynamic data = (await getLocationsJson())['locations'];
  List<Places> result = [];
  for (int i = 0; i < data.length; i++) {
    result.add(Places(
        name: data[i]['name'], lat: data[i]['lat'], long: data[i]['long']));
  }
  return result;
}

bool alreadySaved(List<Places> places, Places place) {
  for (int i = 0; i < places.length; i++) {
    if (place.name == places[i].name) {
      return true;
    }
  }
  return false;
}

Future<File> saveLocation(Places place) async {
  dynamic saved = await getLocationsJson();
  if (saved['locations'] == maxSavedLocations) {
    throw Exception(
        'Can only save a maximum of ${maxSavedLocations.toString()} locations');
  }
  saved['locations'].add(place.toJson());
  return _writeSavedLocations(saved);
}
