import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:src/forecast/forecast.dart';
import 'package:src/util/dates_times.dart';
import 'package:src/util/weather.dart';

const int hourlyMinWidth = 48;
const int hourlyMaxWidth = 236;

const int dailyMaxHeight = 160;

const String weatherIcons = 'assets/icons/weather/';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: Center(
        child: HomeForecast(),
      ),
    ));
  }
}

class HomeForecast extends StatefulWidget {
  const HomeForecast({Key? key}) : super(key: key);

  @override
  _HomeForecastState createState() => _HomeForecastState();
}

class _HomeForecastState extends State<HomeForecast> {
  late Future<ForecastData> futureData;
  bool error = false;
  late String errorMessage;

  @override
  void initState() {
    super.initState();
    futureData = fetchForecastData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ForecastData>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.ready) {
            return RefreshIndicator(
                child: ListView(
                  children: [
                    _buildTopBar(),
                    _buildHeader(snapshot.data!),
                    _buildBody(snapshot.data!)
                  ],
                ),
                onRefresh: () {
                  if (snapshot.data!.currentInfo.date
                      .add(const Duration(minutes: 1))
                      .isAfter(DateTime.now())) {
                    return _refresh(true);
                  } else {
                    return _refresh(false);
                  }
                });
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

  Future<void> _refresh(bool force) async {
    if (force) {
      setState(() {
        futureData = fetchForecastData();
      });
    }
  }

  void _navigateSettings() async {
    dynamic result = await Navigator.pushNamed(context, '/settings');
    _refresh(result ?? false);
  }

  Widget _buildTopBar() => Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.search)),
          GestureDetector(
            onTap: () => _navigateSettings(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.settings),
            ),
          )
        ],
      ));

  Widget _buildLocale(CurrentInfo currentInfo) => Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Center(
          child: Text(
        currentInfo.location,
        style: const TextStyle(fontSize: 18),
      )));

  Widget _buildInfo(CurrentInfo currentInfo) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(1),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      getDate(currentInfo.date),
                      style: const TextStyle(fontSize: 12),
                    ))),
            Container(
                padding: const EdgeInsets.all(1),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getTime(currentInfo.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
          ]);

  Widget _buildTemp(ForecastData forecastData) => Column(
        children: [
          Text(
            forecastData.currentData.temp.round().toString() +
                getUnit(forecastData.isImperial),
            style: const TextStyle(fontSize: 72),
          ),
          Text('feels like: ' +
              forecastData.currentData.feelsLike.round().toString() +
              getUnit(forecastData.isImperial))
        ],
      );

  Widget _buildWeather(ForecastData forecastData) => Container(
      margin: const EdgeInsets.only(left: 32, top: 32),
      child: Column(
        children: [
          getIcon(
              forecastData.currentData.id,
              isDay(
                  forecastData.currentInfo.date,
                  forecastData.currentData.sunrise,
                  forecastData.currentData.sunset)),
          Text(forecastData.currentData.weather)
        ],
      ));

  Widget _buildCurrentForecast(ForecastData forecastData) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              margin: const EdgeInsets.only(right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo(forecastData.currentInfo),
                  _buildTemp(forecastData)
                ],
              )),
          _buildWeather(forecastData)
        ],
      );

  Widget _buildHeader(ForecastData forecastData) => Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          _buildLocale(forecastData.currentInfo),
          _buildCurrentForecast(forecastData)
        ],
      ));

  Widget _buildHour(int index, ForecastData forecastData) {
    List<HourlyForecast> hourlyData = forecastData.hourlyData;
    String hour = getHour(hourlyData[index].time);
    double tempBar = (hourlyData[index].temp.round() - forecastData.hourlyMin) /
        (forecastData.hourlyMax - forecastData.hourlyMin);
    Color? barColor = getBarColor(
        hourlyData[index].id,
        isDay(hourlyData[index].time, forecastData.currentData.sunrise,
            forecastData.currentData.sunset));
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
            Text(hourlyData[index].temp.round().toString() +
                getUnit(forecastData.isImperial))
          ],
        ));
  }

  Widget _buildDetails(ForecastData forecastData) => Container(
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
                        child: Text(getTime(forecastData.currentData.sunrise)))
                  ]),
                  Row(
                    children: [
                      SvgPicture.asset(weatherIcons + 'sunset.svg',
                          width: 48.0, height: 48.0),
                      Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                            getTime(forecastData.currentData.sunset),
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
                              child: Text(forecastData.dailyData[0].high
                                      .round()
                                      .toString() +
                                  getUnit(forecastData.isImperial)))
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
                                  child: Text(forecastData.dailyData[0].low
                                          .round()
                                          .toString() +
                                      getUnit(forecastData.isImperial)))
                            ],
                          )
                        ],
                      )
                    ]))
          ],
        ),
      );

  Widget _buildDaily(ForecastData forecastData) {
    List<Widget> dates = [];
    List<Widget> bars = [];
    for (int i = 0; i < forecastData.dailyData.length; i++) {
      DailyForecast dailyData = forecastData.dailyData[i];
      String date = getWeekday(dailyData.date);
      dates.add(Container(
          padding: const EdgeInsets.all(4),
          width: 58,
          child: Text(
            date,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          )));
      Color? barColor = getBarColor(dailyData.id, true);
      double barLength = (dailyData.high.round() - dailyData.low.round()) /
          (forecastData.dailyMax - forecastData.dailyMin) *
          dailyMaxHeight;
      double topPadding = (1 -
              (dailyData.high - forecastData.dailyMin) /
                  (forecastData.dailyMax - forecastData.dailyMin)) *
          dailyMaxHeight;
      bars.add(Container(
        padding: EdgeInsets.only(top: topPadding, left: 4, right: 4, bottom: 4),
        width: 58,
        child: Column(
          children: [
            Text(dailyData.high.round().toString() +
                getUnit(forecastData.isImperial)),
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
            Text(dailyData.low.round().toString() +
                getUnit(forecastData.isImperial))
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
                children: dates,
              )),
          Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bars,
              ))
        ],
      ),
    );
  }

  Widget _buildBody(ForecastData forecastData) {
    List<Widget> widgets = [];
    for (int i = 0; i < forecastData.hourlyData.length; i++) {
      widgets.add(_buildHour(i, forecastData));
    }
    widgets.add(_buildDetails(forecastData));
    widgets.add(_buildDaily(forecastData));
    return Column(
      children: widgets,
    );
  }
}
