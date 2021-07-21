import 'package:flutter/material.dart';
import 'package:src/forecast/forecast.dart';
import 'package:src/util/dates_times.dart';

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
  }

  String _location = 'loading...';
  late String _date;
  late String _time;
  late int _temp;
  late int _feelsLike;
  late String _condition;

  @override
  Widget build(BuildContext context) {
    // current location
    final locale = Center(child: Text(_location));
    // current date and time
    final info = Column(children: [Text(_date), Text(_time)]);
    // current temperature
    final temperature = Column(
      children: [
        Text(_temp.toString() + ' ºF'),
        Text('feels like: ' + _feelsLike.toString() + ' ºF')
      ],
    );
    // current weather condition
    final weather = Column(
      children: [Text(_condition)],
    );
    // all current data row
    final current = Row(
      children: [
        Column(
          children: [info, temperature],
        ),
        weather
      ],
    );
    return Column(
      children: [locale, current],
    );
  }
}
