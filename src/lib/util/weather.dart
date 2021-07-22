import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String weatherIcons = 'assets/icons/weather/';

Widget getIcon(id, isDay, {width = 90.0, height = 90.0}) {
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

bool isDay(currentTime, sunrise, sunset) {
  return !(currentTime.isBefore(sunrise) || currentTime.isAfter(sunset));
}
