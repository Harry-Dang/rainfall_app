import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:src/env/env.dart';
import 'package:src/location/location.dart';
import 'package:src/util/preferences.dart' as prefs;
import 'package:src/search/search.dart';

const hours = 12;
const days = 6;

class ForecastData {
  int statusCode = -1;
  bool ready = false;

  Places? place;
  bool isImperial = true;

  CurrentData? currentData;
  CurrentInfo? currentInfo;

  List<HourlyForecast> hourlyData = [];
  double? hourlyMin;
  double? hourlyMax;

  List<DailyForecast> dailyData = [];
  double? dailyMin;
  double? dailyMax;

  ForecastData({this.place});

  Future<bool> refresh([Places? place]) async {
    this.place = this.place ?? place;
    isImperial = await prefs.isImperial();
    double lat;
    double long;
    if (place == null && this.place == null) {
      Position position = await getCurrentLocation();
      lat = position.latitude;
      long = position.longitude;
    } else {
      lat = this.place!.lat;
      long = this.place!.long;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=' +
            lat.toString() +
            '&lon=' +
            long.toString() +
            '&appid=' +
            Env.openweather +
            '&units=' +
            (isImperial ? 'imperial' : 'metric')));
    statusCode = response.statusCode;
    if (statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      hourlyData = [];
      for (int i = 0; i < hours; i++) {
        hourlyData.add(HourlyForecast.fromJson(data['hourly'][i]));
        hourlyMin = hourlyData[i].temp <= (hourlyMin ?? hourlyData[i].temp)
            ? hourlyData[i].temp
            : (hourlyMin ?? hourlyData[i].temp);
        hourlyMax = hourlyData[i].temp >= (hourlyMax ?? hourlyData[i].temp)
            ? hourlyData[i].temp
            : (hourlyMax ?? hourlyData[i].temp);
      }
      dailyData = [];
      for (int i = 0; i < days; i++) {
        dailyData.add(DailyForecast.fromJson(data['daily'][i]));
        dailyMin = dailyData[i].low <= (dailyMin ?? dailyData[i].low)
            ? dailyData[i].low
            : (dailyMin ?? dailyData[i].low);
        dailyMax = dailyData[i].high >= (dailyMax ?? dailyData[i].high)
            ? dailyData[i].high
            : (dailyMax ?? dailyData[i].high);
      }
      currentData = CurrentData.fromJson(data['current']);
      currentInfo = CurrentInfo(
          await placemarkFromCoordinates(lat, long), data['current']['dt']);
      ready = true;
      return ready;
    } else {
      return false;
    }
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
  double feelsLike;
  double rain;
  int id;
  String weather;
  double humidity;
  double uvi;
  double windSpeed;
  double windDeg;
  double pressure;

  HourlyForecast(
      {required this.time,
      required this.temp,
      required this.feelsLike,
      required this.rain,
      required this.id,
      required this.weather,
      required this.humidity,
      required this.uvi,
      required this.windSpeed,
      required this.windDeg,
      required this.pressure});

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        temp: json['temp'].toDouble(),
        feelsLike: json['feels_like'].toDouble(),
        rain: json['pop'].toDouble() ?? 0,
        id: json['weather'][0]['id'],
        weather: json['weather'][0]['description'],
        humidity: json['humidity'].toDouble(),
        uvi: json['uvi'].toDouble(),
        windSpeed: json['wind_speed'].toDouble(),
        windDeg: json['wind_deg'].toDouble(),
        pressure: json['pressure'].toDouble());
  }
}

class DailyForecast {
  DateTime date;
  DateTime sunrise;
  DateTime sunset;
  double high;
  double low;
  double rain;
  int id;
  String weather;
  double humidity;
  double uvi;
  double windSpeed;
  double windDeg;
  double pressure;

  DailyForecast(
      {required this.date,
      required this.sunrise,
      required this.sunset,
      required this.high,
      required this.low,
      required this.rain,
      required this.id,
      required this.weather,
      required this.humidity,
      required this.uvi,
      required this.windSpeed,
      required this.windDeg,
      required this.pressure});

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(json['sunset'] * 1000),
        high: json['temp']['max'].toDouble(),
        low: json['temp']['min'].toDouble(),
        rain: json['pop'].toDouble() ?? 0,
        id: json['weather'][0]['id'],
        weather: json['weather'][0]['description'],
        humidity: json['humidity'].toDouble(),
        uvi: json['uvi'].toDouble(),
        windSpeed: json['wind_speed'].toDouble(),
        windDeg: json['wind_deg'].toDouble(),
        pressure: json['pressure'].toDouble());
  }
}
