import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:src/forecast/forecast.dart';
import 'package:src/util/dates_times.dart';
import 'package:src/util/weather.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HomeForecast(),
      ),
    );
  }
}

class HomeForecast extends StatefulWidget {
  const HomeForecast({Key? key}) : super(key: key);

  @override
  _HomeForecastState createState() => _HomeForecastState();
}

class _HomeForecastState extends State<HomeForecast> {
  late Future<ForecastData> futureData;

  String _result = 'loading...';

  @override
  void initState() {
    super.initState();
    futureData = fetchForecastData(38.328732, -85.764771);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ForecastData>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.ready) {
            // return Text(snapshot.data!.currentInfo.location +
            //     '\n' +
            //     snapshot.data!.currentInfo.date.toString() +
            //     '\n' +
            //     snapshot.data!.currentData.temp.toString() +
            //     ' ºF');
            return Header.fromData(
                snapshot.data!.currentData, snapshot.data!.currentInfo);
          } else {
            return Text('Error:\n${snapshot.data!.statusCode}');
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class Header extends StatelessWidget {
  Header({Key? key}) : super(key: key);

  Header.fromData(currentData, currentInfo) {
    _location = currentInfo.location;
    _date = getDate(currentInfo.date);
    _time = getTime(currentInfo.date);
    _temp = currentData.temp.round();
    _feelsLike = currentData.feelsLike.round();
    _condition = currentData.weather;
    _id = currentData.id;
    _isDay = isDay(currentInfo.date, currentData.sunrise, currentData.sunset);
  }

  String _location = 'loading...';
  late String _date;
  late String _time;
  late int _temp;
  late int _feelsLike;
  late String _condition;
  late int _id;
  late bool _isDay;

  @override
  Widget build(BuildContext context) {
    // current location
    final locale = Container(
        margin: const EdgeInsets.only(top: 30, bottom: 15),
        child: Center(
            child: Text(
          _location,
          style: const TextStyle(fontSize: 18),
        )));
    // current date and time
    final info = Column(children: [
      Container(
          padding: const EdgeInsets.all(1),
          margin: const EdgeInsets.only(right: 96),
          child: Text(
            _date,
            style: const TextStyle(fontSize: 12),
          )),
      Container(
        padding: const EdgeInsets.all(1),
        margin: const EdgeInsets.only(right: 96),
        child: Text(
          _time,
          style: const TextStyle(fontSize: 12),
        ),
      )
    ]);
    // current temperature
    final temperature = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          _temp.toString() + 'ºF',
          style: const TextStyle(fontSize: 72),
        ),
        Text('feels like: ' + _feelsLike.toString() + 'ºF')
      ],
    );
    // current weather condition
    final weather = Container(
        margin: const EdgeInsets.only(left: 32, top: 32),
        child: Column(
          children: [getIcon(_id, _isDay), Text(_condition)],
        ));
    // all current data row
    final current = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
            margin: const EdgeInsets.only(right: 32),
            child: Column(
              children: [info, temperature],
            )),
        weather
      ],
    );
    return Column(
      children: [locale, current],
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
