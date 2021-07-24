import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:src/util/preferences.dart';

const String weatherIcons = 'assets/icons/weather/';

Widget getIcon(int id, bool isDay,
    {double width = 90.0, double height = 90.0}) {
  if (id == 800) {
    if (isDay) {
      return SvgPicture.asset(
        weatherIcons + 'sun.svg',
        width: width,
        height: height,
      );
    } else {
      return SvgPicture.asset(
        weatherIcons + 'moon.svg',
        width: width,
        height: height,
      );
    }
  } else if (id == 801) {
    if (isDay) {
      return SvgPicture.asset(
        weatherIcons + 'cloudy_sun.svg',
        width: width,
        height: height,
      );
    } else {
      return SvgPicture.asset(
        weatherIcons + 'cloudy_moon.svg',
        width: width,
        height: height,
      );
    }
  } else if (id == 802) {
    return SvgPicture.asset(
      weatherIcons + 'cloudy.svg',
      width: width,
      height: height,
    );
  } else if (id == 803 || id == 804) {
    return SvgPicture.asset(
      weatherIcons + 'overcast.svg',
      width: width,
      height: height,
    );
  } else if (id >= 200 && id <= 232) {
    return SvgPicture.asset(
      weatherIcons + 'thunderstorm.svg',
      width: width,
      height: height,
    );
  } else if (id >= 300 && id <= 321) {
    return SvgPicture.asset(
      weatherIcons + 'rainy.svg',
      width: width,
      height: height,
    );
  } else if (id >= 500 && id <= 531) {
    return SvgPicture.asset(
      weatherIcons + 'storm.svg',
      width: width,
      height: height,
    );
  } else if (id >= 600 && id <= 622) {
    return SvgPicture.asset(
      weatherIcons + 'snowy.svg',
      width: width,
      height: height,
    );
  } else if (id >= 700 && id <= 781) {
    return SvgPicture.asset(
      weatherIcons + 'fog.svg',
      width: width,
      height: height,
    );
  } else {
    return SvgPicture.asset(
      weatherIcons + 'sun.svg',
      width: width,
      height: height,
    );
  }
}

bool isDay(DateTime currentTime, DateTime sunrise, DateTime sunset) {
  return !(currentTime.isBefore(sunrise) || currentTime.isAfter(sunset));
}

Color? getBarColor(int id, bool isDay) {
  if (id <= 531 && id >= 200) {
    // rain
    return Colors.blue[300];
  } else if (id <= 622 && id >= 600) {
    // snow
    return Colors.white;
  } else if (id == 800) {
    // sunny
    if (isDay) {
      return Colors.yellow[300];
    } else {
      return Colors.purple[900];
    }
  } else if (id == 801) {
    // cloudy
    return Colors.grey[300];
  } else if (id == 802) {
    return Colors.grey[400];
  } else if (id == 803) {
    return Colors.grey;
  } else if (id == 804) {
    return Colors.grey[600];
  } else if (id >= 701 && id <= 781) {
    // atmosphere stuff
    return Colors.grey[400];
  } else {
    return Colors.yellow[200];
  }
}

String getUnit() {
  isImperial().then((value) => value ? 'ºF' : 'ºC');
  return 'ºF';
}
