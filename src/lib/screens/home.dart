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
  late Future<ForecastData> futureData;

  String _result = 'loading...';

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
            return Text(snapshot.data!.currentData.temp.toString() + ' ºF');
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
