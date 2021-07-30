import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:src/forecast/forecast.dart';
import 'package:src/util/dates_times.dart';
import 'package:src/util/weather.dart';

const int hourlyMinWidth = 48;

const int dailyMaxHeight = 160;

const String weatherIcons = 'assets/icons/weather/';

class ForecastPage extends StatelessWidget {
  final ForecastData forecastData;

  const ForecastPage({Key? key, required this.forecastData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecastData.ready) {
      return RefreshIndicator(
          child: ListView(
            children: [_buildHeader(), _buildBody(context)],
          ),
          onRefresh: () async {
            forecastData.refresh();
          });
    } else {
      return FutureBuilder(
        future: forecastData.refresh(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              if (forecastData.ready) {
                return RefreshIndicator(
                    child: ListView(
                      children: [_buildHeader(), _buildBody(context)],
                    ),
                    onRefresh: () async {
                      forecastData.refresh();
                    });
              } else {
                return const Center(
                  child: Text('forecastData not ready'),
                );
              }
            } else {
              return Center(
                child: Text(snapshot.data.toString()),
              );
            }
          } else if (snapshot.hasError) {
            return const Text('error');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }

  Widget _buildHeader() => Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [_buildLocale(), _buildCurrentForecast()],
      ));

  Widget _buildLocale() {
    return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Center(
            child: Text(
          forecastData.currentInfo!.location,
          style: const TextStyle(fontSize: 18),
        )));
  }

  Widget _buildCurrentForecast() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              margin: const EdgeInsets.only(right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildInfo(), _buildTemp()],
              )),
          _buildWeather()
        ],
      );

  Widget _buildInfo() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(1),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      getDate(forecastData.currentInfo!.date),
                      style: const TextStyle(fontSize: 12),
                    ))),
            Container(
                padding: const EdgeInsets.all(1),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getTime(forecastData.currentInfo!.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
          ]);

  Widget _buildTemp() => Column(
        children: [
          Text(
            forecastData.currentData!.temp.round().toString() +
                getUnit(forecastData.isImperial),
            style: const TextStyle(fontSize: 72),
          ),
          Text('feels like: ' +
              forecastData.currentData!.feelsLike.round().toString() +
              getUnit(forecastData.isImperial))
        ],
      );

  Widget _buildWeather() => Container(
      margin: const EdgeInsets.only(left: 32, top: 32),
      child: Column(
        children: [
          getIcon(
              forecastData.currentData!.id,
              isDay(
                  forecastData.currentInfo!.date,
                  forecastData.currentData!.sunrise,
                  forecastData.currentData!.sunset)),
          Text(forecastData.currentData!.weather)
        ],
      ));

  Widget _buildBody(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < forecastData.hourlyData.length; i++) {
      widgets.add(_buildHour(context, i));
    }
    widgets.add(_buildDetails());
    widgets.add(_buildDaily());
    return Column(
      children: widgets,
    );
  }

  Widget _buildHour(BuildContext context, int index) {
    List<HourlyForecast> hourlyData = forecastData.hourlyData;
    String hour = getHour(hourlyData[index].time);
    double hourlyMaxWidth = MediaQuery.of(context).size.shortestSide * 0.55;
    double tempBar =
        (hourlyData[index].temp.round() - forecastData.hourlyMin!.round()) /
            (forecastData.hourlyMax!.round() - forecastData.hourlyMin!.round());
    Color? barColor = getBarColor(
        hourlyData[index].id,
        isDay(
            hourlyData[index].time,
            hourlyData[index].time.day == forecastData.currentInfo!.date.day
                ? forecastData.currentData!.sunrise
                : forecastData.dailyData[1].sunrise,
            hourlyData[index].time.day == forecastData.currentInfo!.date.day
                ? forecastData.currentData!.sunset
                : forecastData.dailyData[1].sunset));
    String rain = hourlyData[index].rain >= 0.25 ||
            (hourlyData[index].id <= 531 && hourlyData[index].id >= 200)
        ? (hourlyData[index].rain * 100).toInt().toString() + "%"
        : '';
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

  Widget _buildDetails() => Container(
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
                        child: Text(getTime(forecastData.currentData!.sunrise)))
                  ]),
                  Row(
                    children: [
                      SvgPicture.asset(weatherIcons + 'sunset.svg',
                          width: 48.0, height: 48.0),
                      Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                            getTime(forecastData.currentData!.sunset),
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

  Widget _buildDaily() {
    List<Widget> daily = [];
    for (int i = 0; i < forecastData.dailyData.length; i++) {
      DailyForecast dailyData = forecastData.dailyData[i];
      Color? barColor = getBarColor(dailyData.id, true);
      double barLength = (dailyData.high.round() - dailyData.low.round()) /
          (forecastData.dailyMax! - forecastData.dailyMin!) *
          dailyMaxHeight;
      double topPadding = (1 -
              (dailyData.high - forecastData.dailyMin!) /
                  (forecastData.dailyMax! - forecastData.dailyMin!)) *
          dailyMaxHeight;
      daily.add(Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                getWeekday(dailyData.date),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: topPadding),
              child: Text(dailyData.high.round().toString() +
                  getUnit(forecastData.isImperial)),
            ),
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
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(dailyData.low.round().toString() +
                  getUnit(forecastData.isImperial)),
            )
          ],
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: daily,
      ),
    );
  }
}
