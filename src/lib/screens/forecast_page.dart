import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:src/forecast/forecast.dart';
import 'package:src/util/dates_times.dart';
import 'package:src/util/weather.dart';

const int hourlyMinWidth = 48;

const int dailyMaxHeight = 160;

const String weatherIcons = 'assets/icons/weather/';

class ForecastPage extends StatefulWidget {
  final ForecastData forecastData;
  final VoidCallback refresh;

  const ForecastPage(
      {Key? key, required this.forecastData, required this.refresh})
      : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  int _hourlyExpand = -1;
  int _dailyExpand = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.forecastData.ready) {
      return RefreshIndicator(
          child: ListView(
            children: [_buildHeader(), _buildBody(context)],
          ),
          onRefresh: () async {
            // forecastData.refresh();
            widget.refresh();
          });
    } else {
      return FutureBuilder(
        future: widget.forecastData.refresh(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              if (widget.forecastData.ready) {
                return RefreshIndicator(
                    child: ListView(
                      children: [_buildHeader(), _buildBody(context)],
                    ),
                    onRefresh: () async {
                      // forecastData.refresh();
                      widget.refresh();
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
          widget.forecastData.currentInfo!.location,
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
                      getDate(widget.forecastData.currentInfo!.date),
                      style: const TextStyle(fontSize: 12),
                    ))),
            Container(
                padding: const EdgeInsets.all(1),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getTime(widget.forecastData.currentInfo!.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
          ]);

  Widget _buildTemp() => Column(
        children: [
          Text(
            widget.forecastData.currentData!.temp.round().toString() +
                getUnit(widget.forecastData.isImperial),
            style: const TextStyle(fontSize: 72),
          ),
          Text('feels like: ' +
              widget.forecastData.currentData!.feelsLike.round().toString() +
              getUnit(widget.forecastData.isImperial))
        ],
      );

  Widget _buildWeather() => Container(
      margin: const EdgeInsets.only(left: 32, top: 32),
      child: Column(
        children: [
          getIcon(
              widget.forecastData.currentData!.id,
              isDay(
                  widget.forecastData.currentInfo!.date,
                  widget.forecastData.currentData!.sunrise,
                  widget.forecastData.currentData!.sunset)),
          Text(widget.forecastData.currentData!.weather)
        ],
      ));

  Widget _buildBody(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.forecastData.hourlyData.length; i++) {
      widgets.add(_buildHour(context, i));
    }
    widgets.add(_buildDetails());
    if (_dailyExpand == -1) {
      widgets.add(_buildDaily());
    } else {
      widgets.add(_buildDailyDetail());
    }
    return Column(
      children: widgets,
    );
  }

  Widget _buildHour(BuildContext context, int index) {
    List<HourlyForecast> hourlyData = widget.forecastData.hourlyData;
    String hour = getHour(hourlyData[index].time);
    double hourlyMaxWidth = MediaQuery.of(context).size.shortestSide * 0.55;
    double tempBar = (hourlyData[index].temp.round() -
            widget.forecastData.hourlyMin!.round()) /
        (widget.forecastData.hourlyMax!.round() -
            widget.forecastData.hourlyMin!.round());
    bool isDaytime = isDay(
        hourlyData[index].time,
        hourlyData[index].time.day == widget.forecastData.currentInfo!.date.day
            ? widget.forecastData.currentData!.sunrise
            : widget.forecastData.dailyData[1].sunrise,
        hourlyData[index].time.day == widget.forecastData.currentInfo!.date.day
            ? widget.forecastData.currentData!.sunset
            : widget.forecastData.dailyData[1].sunset);
    Color? barColor = getBarColor(hourlyData[index].id, isDaytime);
    String rain = hourlyData[index].rain >= 0.25 ||
            (hourlyData[index].id <= 531 && hourlyData[index].id >= 200)
        ? (hourlyData[index].rain * 100).toInt().toString() + "%"
        : '';
    Color? textColor =
        barColor == Colors.grey[600] || barColor == Colors.purple[900]
            ? Colors.white
            : Colors.black;
    Widget mainBar = Container(
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
                child: Text(
                  rain,
                  style: TextStyle(color: textColor),
                ),
              ),
              decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.all(Radius.circular(90.0)),
                  border: Border.all(
                      color: barColor == Colors.white
                          ? Colors.grey
                          : Colors.transparent)),
            ),
            Text(hourlyData[index].temp.round().toString() +
                getUnit(widget.forecastData.isImperial))
          ],
        ));
    if (_hourlyExpand == index) {
      Widget details = Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // left column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // weather
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 4),
                    child: getIcon(hourlyData[index].id, isDaytime,
                        width: 32, height: 32),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Text(hourlyData[index].weather),
                  )
                ],
              ),
              // humdity
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 4),
                    child: SvgPicture.asset(weatherIcons + 'humidity.svg',
                        width: 32, height: 32),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Humidity'),
                        Text(
                            hourlyData[index].humidity.round().toString() + '%')
                      ],
                    ),
                  )
                ],
              ),
              // wind
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 4),
                    child: SvgPicture.asset(
                      weatherIcons + 'windy.svg',
                      width: 32,
                      height: 32,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wind'),
                          Text(hourlyData[index].windSpeed.toString() +
                              ' ' +
                              getSpeedUnit(widget.forecastData.isImperial) +
                              ' ' +
                              getWindDirection(hourlyData[index].windDeg))
                        ],
                      ))
                ],
              )
            ],
          ),
          // right column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // feels like
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 4),
                    child: SvgPicture.asset(weatherIcons + 'thermometer.svg',
                        width: 32, height: 32),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Feels like'),
                        Text(hourlyData[index].feelsLike.round().toString() +
                            getUnit(widget.forecastData.isImperial))
                      ],
                    ),
                  )
                ],
              ),
              // UV index
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 4),
                    child: SvgPicture.asset(weatherIcons + 'sun.svg',
                        width: 32, height: 32),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('UV Index'),
                        Text(hourlyData[index].uvi.toString())
                      ],
                    ),
                  )
                ],
              ),
              // pressure
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(right: 4),
                      child: SvgPicture.asset(weatherIcons + 'compass.svg',
                          width: 32, height: 32)),
                  Container(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pressure'),
                          Text(hourlyData[index].pressure.toString() +
                              ' ' +
                              'hPa')
                        ],
                      ))
                ],
              )
            ],
          )
        ]),
      );
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [mainBar, details],
        ),
        onTap: () {
          setState(() {
            _hourlyExpand = -1;
          });
        },
      );
    } else {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: mainBar,
        onTap: () {
          setState(() {
            _hourlyExpand = index;
          });
        },
      );
    }
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
                        child: Text(
                            getTime(widget.forecastData.currentData!.sunrise)))
                  ]),
                  Row(
                    children: [
                      SvgPicture.asset(weatherIcons + 'sunset.svg',
                          width: 48.0, height: 48.0),
                      Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                            getTime(widget.forecastData.currentData!.sunset),
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
                              child: Text(widget.forecastData.dailyData[0].high
                                      .round()
                                      .toString() +
                                  getUnit(widget.forecastData.isImperial)))
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
                                  child: Text(widget
                                          .forecastData.dailyData[0].low
                                          .round()
                                          .toString() +
                                      getUnit(widget.forecastData.isImperial)))
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
    for (int i = 0; i < widget.forecastData.dailyData.length; i++) {
      daily.add(_buildDailyBar(i, false));
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

  Widget _buildDailyDetail() {
    DailyForecast dailyData = widget.forecastData.dailyData[_dailyExpand];
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDailyBar(_dailyExpand, true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: EdgeInsets.only(right: deviceWidth * 0.1),
                      child: Text(
                        getDate(dailyData.date),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: getIcon(dailyData.id, true,
                              width: 60, height: 60),
                        ),
                        Text(dailyData.weather)
                      ],
                    )
                  ],
                ),
                Container(
                    // color: Colors.green,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // left column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // humidity
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.only(right: 4),
                                  child: SvgPicture.asset(
                                      weatherIcons + 'humidity.svg',
                                      width: 32,
                                      height: 32),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Humidity'),
                                      Text(dailyData.humidity
                                              .round()
                                              .toString() +
                                          '%')
                                    ],
                                  ),
                                )
                              ],
                            ),
                            // wind
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.only(right: 4),
                                  child: SvgPicture.asset(
                                    weatherIcons + 'windy.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Wind'),
                                        Text(dailyData.windSpeed.toString() +
                                            ' ' +
                                            getSpeedUnit(widget
                                                .forecastData.isImperial) +
                                            ' ' +
                                            getWindDirection(dailyData.windDeg))
                                      ],
                                    ))
                              ],
                            )
                          ],
                        ),
                        // right column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.only(right: 4),
                                  child: SvgPicture.asset(
                                      weatherIcons + 'sun.svg',
                                      width: 32,
                                      height: 32),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('UV Index'),
                                      Text(dailyData.uvi.toString())
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(4),
                                    margin: const EdgeInsets.only(right: 4),
                                    child: SvgPicture.asset(
                                        weatherIcons + 'compass.svg',
                                        width: 32,
                                        height: 32)),
                                Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Pressure'),
                                        Text(dailyData.pressure.toString() +
                                            ' ' +
                                            'hPa')
                                      ],
                                    ))
                              ],
                            )
                          ],
                        )
                      ],
                    ))
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _dailyExpand = -1;
        });
      },
    );
  }

  Widget _buildDailyBar(int i, bool expanded) {
    DailyForecast dailyData = widget.forecastData.dailyData[i];
    Color? barColor = getBarColor(dailyData.id, true);
    double barLength = (dailyData.high.round() - dailyData.low.round()) /
        (widget.forecastData.dailyMax! - widget.forecastData.dailyMin!) *
        dailyMaxHeight;
    double topPadding = (1 -
            (dailyData.high - widget.forecastData.dailyMin!) /
                (widget.forecastData.dailyMax! -
                    widget.forecastData.dailyMin!)) *
        dailyMaxHeight;
    String rain =
        dailyData.rain >= 0.25 || (dailyData.id <= 531 && dailyData.id >= 200)
            ? (dailyData.rain * 100).toInt().toString() + "%"
            : '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                  getUnit(widget.forecastData.isImperial)),
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
              child: Text(dailyData.low.round().toString() +
                  getUnit(widget.forecastData.isImperial)),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(rain),
            )
          ],
        ),
      ),
      onTap: () {
        if (expanded) {
          setState(() {
            _dailyExpand = -1;
          });
        } else {
          setState(() {
            _dailyExpand = i;
          });
        }
      },
    );
  }
}
