import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:src/env/env.dart';

Future<ForecastData> fetchForecastData() async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/onecall?lat=38.328732&lon=-85.764771&exclude={part}&appid=' +
          Env.openweather +
          '&units=imperial'));
  if (response.statusCode == 200) {
    print(jsonDecode(response.body)['current']);
    print(jsonDecode(response.body)['current']['weather'][0]);
    return ForecastData(response.statusCode,
        CurrentData.fromJson(jsonDecode(response.body)['current']));
  } else {
    return ForecastData(response.statusCode);
  }
}

class ForecastData {
  int statusCode = -1;
  bool ready = false;
  late CurrentData currentData;

  ForecastData(this.statusCode, [current]) {
    ready = statusCode == 200;
    currentData = current;
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
