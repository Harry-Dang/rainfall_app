import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

import 'package:src/env/env.dart';

const hours = 12;

Future<ForecastData> fetchForecastData(double lat, double long) async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/onecall?lat=${lat.toString()}&lon=${long.toString()}&appid=' +
          Env.openweather +
          '&units=imperial'));
  if (response.statusCode == 200) {
    dynamic data = jsonDecode(response.body);
    List<HourlyForecast> hourly = [];
    double? min;
    double? max;
    for (int i = 0; i < hours; i++) {
      hourly.add(HourlyForecast.fromJson(data['hourly'][i]));
      min = hourly[i].temp <= (min ?? hourly[i].temp)
          ? hourly[i].temp
          : (min ?? hourly[i].temp);
      max = hourly[i].temp >= (max ?? hourly[i].temp)
          ? hourly[i].temp
          : (max ?? hourly[i].temp);
    }
    ForecastData result = ForecastData(
        response.statusCode,
        CurrentData.fromJson(data['current']),
        CurrentInfo(
            await placemarkFromCoordinates(lat, long), data['current']['dt']),
        hourly);
    result.setHourlyMin(min!);
    result.setHourlyMax(max!);
    return result;
  } else {
    return ForecastData(response.statusCode);
  }
}

class ForecastData {
  int statusCode = -1;
  bool ready = false;
  late CurrentData currentData;
  late CurrentInfo currentInfo;
  late List<HourlyForecast> hourlyData;
  late double hourlyMin;
  late double hourlyMax;

  ForecastData(this.statusCode, [current, info, hourly]) {
    ready = statusCode == 200;
    currentData = current;
    currentInfo = info;
    hourlyData = hourly;
  }

  void setHourlyMin(double min) {
    hourlyMin = min;
  }

  void setHourlyMax(double max) {
    hourlyMax = max;
  }
}

class CurrentData {
  double temp;
  double feelsLike;
  String weather;
  int id;
  DateTime sunrise;
  DateTime sunset;

  CurrentData(
      {required this.temp,
      required this.feelsLike,
      required this.weather,
      required this.id,
      required this.sunrise,
      required this.sunset});

  factory CurrentData.fromJson(Map<String, dynamic> json) {
    return CurrentData(
        temp: json['temp'],
        feelsLike: json['feels_like'],
        weather: json['weather'][0]['main'],
        id: json['weather'][0]['id'],
        sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(json['sunset'] * 1000));
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

class HourlyForecast {
  DateTime time;
  double temp;
  int rain;
  int id;

  HourlyForecast(
      {required this.time,
      required this.temp,
      required this.rain,
      required this.id});

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        temp: json['temp'],
        rain: json['pop'],
        id: json['weather'][0]['id']);
  }
}
