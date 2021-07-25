import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:src/env/env.dart';
import 'package:src/location/location.dart';
import 'package:src/util/preferences.dart';
import 'package:src/search/search.dart';

const hours = 12;
const days = 6;

Future<ForecastData> fetchForecastData([Places? place]) async {
  bool imperial = await isImperial();
  double lat;
  double long;
  if (place == null) {
    Position position = await getCurrentLocation();
    lat = position.latitude;
    long = position.longitude;
  } else {
    lat = place.lat;
    long = place.long;
  }
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/onecall?lat=' +
          lat.toString() +
          '&lon=' +
          long.toString() +
          '&appid=' +
          Env.openweather +
          '&units=' +
          (imperial ? 'imperial' : 'metric')));
  if (response.statusCode == 200) {
    dynamic data = jsonDecode(response.body);
    List<HourlyForecast> hourly = [];
    double? hourlyMin;
    double? hourlyMax;
    for (int i = 0; i < hours; i++) {
      hourly.add(HourlyForecast.fromJson(data['hourly'][i]));
      hourlyMin = hourly[i].temp <= (hourlyMin ?? hourly[i].temp)
          ? hourly[i].temp
          : (hourlyMin ?? hourly[i].temp);
      hourlyMax = hourly[i].temp >= (hourlyMax ?? hourly[i].temp)
          ? hourly[i].temp
          : (hourlyMax ?? hourly[i].temp);
    }
    List<DailyForecast> daily = [];
    double? dailyMin;
    double? dailyMax;
    for (int i = 0; i < days; i++) {
      daily.add(DailyForecast.fromJson(data['daily'][i]));
      dailyMin = daily[i].low <= (dailyMin ?? daily[i].low)
          ? daily[i].low
          : (dailyMin ?? daily[i].low);
      dailyMax = daily[i].high >= (dailyMax ?? daily[i].high)
          ? daily[i].high
          : (dailyMax ?? daily[i].high);
    }
    ForecastData result = ForecastData(
        response.statusCode,
        imperial,
        CurrentData.fromJson(data['current']),
        CurrentInfo(
            await placemarkFromCoordinates(lat, long), data['current']['dt']),
        hourly,
        daily);
    result.hourlyMin = hourlyMin!;
    result.hourlyMax = hourlyMax!;
    result.dailyMin = dailyMin!;
    result.dailyMax = dailyMax!;
    return result;
  } else {
    return ForecastData(response.statusCode, imperial);
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
  late List<DailyForecast> dailyData;
  late double dailyMin;
  late double dailyMax;
  late bool isImperial;

  ForecastData(this.statusCode, this.isImperial,
      [current, info, hourly, daily]) {
    ready = statusCode == 200;
    currentData = current;
    currentInfo = info;
    hourlyData = hourly;
    dailyData = daily;
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
        temp: json['temp'].toDouble(),
        feelsLike: json['feels_like'].toDouble(),
        weather: json['weather'][0]['description'],
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
  double rain;
  int id;

  HourlyForecast(
      {required this.time,
      required this.temp,
      required this.rain,
      required this.id});

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        temp: json['temp'].toDouble(),
        rain: json['pop'].toDouble(),
        id: json['weather'][0]['id']);
  }
}

class DailyForecast {
  DateTime date;
  DateTime sunrise;
  DateTime sunset;
  double high;
  double low;
  int id;

  DailyForecast(
      {required this.date,
      required this.sunrise,
      required this.sunset,
      required this.high,
      required this.low,
      required this.id});

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(json['sunset'] * 1000),
        high: json['temp']['max'].toDouble(),
        low: json['temp']['min'].toDouble(),
        id: json['weather'][0]['id']);
  }
}
