import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:src/forecast/forecast.dart';
import 'package:src/util/dates_times.dart';
import 'package:src/util/weather.dart';

const int hourlyMinWidth = 48;
const int hourlyMaxWidth = 240;

const int dailyMaxHeight = 160;

const String weatherIcons = 'assets/icons/weather/';

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
        margin: const EdgeInsets.only(bottom: 15),
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

  late ForecastData _forecastData;

  Body.fromData(ForecastData forecastData) {
    _forecastData = forecastData;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < _forecastData.hourlyData.length; i++) {
      widgets.add(buildHour(i));
    }
    widgets.add(buildDetails());
    // List<Widget> dailyForecast = [];
    // for (int i = 0; i < _forecastData.dailyData.length; i++) {
    //   dailyForecast.add(buildDaily(i));
    // }
    // widgets.add(Container(
    //     padding: const EdgeInsets.only(left: 24, right: 24),
    //     child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         children: dailyForecast)));
    // return Column(
    //   children: widgets,
    // );
    widgets.add(buildDaily());
    return Column(
      children: widgets,
    );
  }

  Widget buildHour(int index) {
    List<HourlyForecast> hourlyData = _forecastData.hourlyData;
    String hour = getHour(hourlyData[index].time);
    double tempBar = (hourlyData[index].temp - _forecastData.hourlyMin) /
        (_forecastData.hourlyMax - _forecastData.hourlyMin);
    Color? barColor = getBarColor(
        hourlyData[index].id,
        isDay(hourlyData[index].time, _forecastData.currentData.sunrise,
            _forecastData.currentData.sunset));
    String rain = hourlyData[index].rain == 0
        ? ''
        : hourlyData[index].rain.toString() + "%";
    return Container(
        padding: EdgeInsets.only(
            top: 10, bottom: 10, left: hour.length == 5 ? 32 : 40, right: 40),
        child: Row(
          children: [
            Text(hour),
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              height: 24,
              width:
                  (hourlyMaxWidth - hourlyMinWidth) * tempBar + hourlyMinWidth,
              child: Container(
                  padding: const EdgeInsets.only(left: 8, top: 3),
                  child: Text(rain)),
              decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.all(Radius.circular(90.0)),
                  border: Border.all(
                      color: barColor == Colors.white
                          ? Colors.grey
                          : Colors.transparent)),
            ),
            Text(hourlyData[index].temp.round().toString() + 'ºF')
          ],
        ));
  }

  Widget buildDetails() {
    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        children: [
          // sunrise sunset
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12),
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(children: [
                  SvgPicture.asset(weatherIcons + 'sunrise.svg',
                      width: 48.0, height: 48.0),
                  Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(getTime(_forecastData.currentData.sunrise)))
                ]),
                Row(
                  children: [
                    SvgPicture.asset(weatherIcons + 'sunset.svg',
                        width: 48.0, height: 48.0),
                    Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          getTime(_forecastData.currentData.sunset),
                        ))
                  ],
                )
              ],
            ),
          ),
          // high and low
          Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              margin: const EdgeInsets.only(top: 6, bottom: 6),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(weatherIcons + 'warm.svg',
                            width: 48.0, height: 48.0),
                        Container(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(_forecastData.dailyData[0].high
                                    .round()
                                    .toString() +
                                'ºF'))
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(weatherIcons + 'cold.svg',
                                width: 48.0, height: 48.0),
                            Container(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Text(_forecastData.dailyData[0].low
                                        .round()
                                        .toString() +
                                    'ºF'))
                          ],
                        )
                      ],
                    )
                  ]))
        ],
      ),
    );
  }

  Widget buildDaily() {
    List<Widget> dates = [];
    List<Widget> bars = [];
    for (int i = 0; i < _forecastData.dailyData.length; i++) {
      DailyForecast dailyData = _forecastData.dailyData[i];
      String date = getWeekday(dailyData.date);
      dates.add(Container(
          padding: const EdgeInsets.all(4),
          width: 52,
          child: Text(
            date,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          )));
      Color? barColor = getBarColor(dailyData.id, true);
      double barLength = (dailyData.high - dailyData.low) /
          (_forecastData.dailyMax - _forecastData.dailyMin) *
          dailyMaxHeight;
      bars.add(Container(
        padding: const EdgeInsets.all(4),
        width: 52,
        child: Column(
          children: [
            Text(dailyData.high.round().toString() + 'ºF'),
            Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                height: barLength,
                width: 24,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.all(Radius.circular(90.0)),
                  border: Border.all(
                      color: barColor == Colors.white
                          ? Colors.grey
                          : Colors.transparent),
                )),
            Text(dailyData.low.round().toString() + 'ºF')
          ],
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dates,
              )),
          Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: bars,
              ))
        ],
      ),
    );
  }
}
