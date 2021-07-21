import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

import 'package:src/env/env.dart';

Future<ForecastData> fetchForecastData(lat, long) async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/onecall?lat=${lat.toString()}&lon=${long.toString()}&appid=' +
          Env.openweather +
          '&units=imperial'));
  if (response.statusCode == 200) {
    dynamic data = jsonDecode(response.body);
    return ForecastData(
        response.statusCode,
        CurrentData.fromJson(data['current']),
        CurrentInfo(
            await placemarkFromCoordinates(lat, long), data['current']['dt']));
  } else {
    return ForecastData(response.statusCode);
  }
}

class ForecastData {
  int statusCode = -1;
  bool ready = false;
  late CurrentData currentData;
  late CurrentInfo currentInfo;

  ForecastData(this.statusCode, [current, info]) {
    ready = statusCode == 200;
    currentData = current;
    currentInfo = info;
  }
}

class CurrentData {
  double temp;
  double feelsLike;
  String weather;

  CurrentData({
    required this.temp,
    required this.feelsLike,
    required this.weather,
  });

  factory CurrentData.fromJson(Map<String, dynamic> json) {
    return CurrentData(
        temp: json['temp'],
        feelsLike: json['feels_like'],
        weather: json['weather'][0]['main']);
  }
}

class CurrentInfo {
  late String location;
  late DateTime date;

  CurrentInfo(placemark, dt) {
    Placemark currentLocation = placemark[0];
    location =
        currentLocation.locality! + ', ' + currentLocation.administrativeArea!;
    date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
  }
}
