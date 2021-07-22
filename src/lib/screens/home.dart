import 'package:flutter/material.dart';

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
            return ListView(
              children: [
                Header.fromData(
                    snapshot.data!.currentData, snapshot.data!.currentInfo),
                Body.fromData(snapshot.data!)
              ],
            );
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

  Header.fromData(CurrentData currentData, CurrentInfo currentInfo) {
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
    final info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(1),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _date,
                    style: const TextStyle(fontSize: 12),
                  ))),
          Container(
              padding: const EdgeInsets.all(1),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _time,
                  style: const TextStyle(fontSize: 12),
                ),
              ))
        ]);
    // current temperature
    final temperature = Column(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [info, temperature],
            )),
        weather
      ],
    );
    return Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          children: [locale, current],
        ));
  }
}

class Body extends StatelessWidget {
  Body({Key? key}) : super(key: key);

  late List<HourlyForecast> _hourlyData;

  Body.fromData(ForecastData forecastData) {
    _hourlyData = forecastData.hourlyData;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> hours = [];
    for (int i = 0; i < _hourlyData.length; i++) {
      hours.add(buildHour(i));
    }
    return Column(
      children: hours,
    );
  }

  Widget buildHour(int index) {
    return Container(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Row(
          children: [
            Text(getHour(_hourlyData[index].time)),
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              height: 24,
              width: 160,
              decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(90.0))),
            ),
            Text(_hourlyData[index].temp.round().toString() + 'ºF')
          ],
        ));
  }
}
