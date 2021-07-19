import 'package:flutter/material.dart';
import 'package:src/forecast/forecast.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

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
  ForecastData _forecastData = ForecastData();

  String _result = 'loading...';

  void getText() {
    final response = _forecastData.fetchData();
    response.then((value) {
      if (value.statusCode == 200) {
        setState(() {
          _result = value.body;
        });
      } else {
        setState(() {
          _result = 'Status code = ' + value.statusCode.toString();
        });
      }
    }, onError: (e) {
      setState(() {
        _result = 'HTTP error';
      });
    });
  }

  @override
  void initState() {
    getText();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_result);
  }
}
