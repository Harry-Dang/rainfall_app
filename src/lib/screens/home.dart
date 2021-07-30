import 'package:flutter/material.dart';
import 'package:src/forecast/forecast.dart';

import 'package:src/screens/forecast_page.dart';
import 'package:src/search/search.dart';
import 'package:src/util/save.dart';

const int hourlyMinWidth = 48;

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
  late Future<List<Places>> _futureAllPlaces;
  List<Places> _allPlaces = [];

  List<ForecastData> _allForecastData = [];
  List<ForecastPage> _pages = [];

  final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);

  bool error = false;
  late String errorMessage;

  @override
  void initState() {
    super.initState();
    _futureAllPlaces = getPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildTopBar(),
      FutureBuilder<List<Places>>(
        future: _futureAllPlaces,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allPlaces = snapshot.data!;
            return Expanded(
              child: PageView.builder(
                  itemCount: _allPlaces.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ForecastPage(forecastData: ForecastData());
                    } else {
                      return ForecastPage(
                          forecastData:
                              ForecastData(place: _allPlaces[index - 1]));
                    }
                  }),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    ]);
  }

  void _navigateSettings() async {
    dynamic result = await Navigator.pushNamed(context, '/settings');
    if (result ?? false) {
      List<Places> result = await getPlaces();
      setState(() {
        _futureAllPlaces = getPlaces();
        _allPlaces = result;
      });
    }
  }

  void _navigateSearch() async {
    dynamic result = await Navigator.pushNamed(context, '/search');
    if (result == null) {
      _pageController.jumpToPage(0);
    }
    if (result is Places) {
      setState(() {
        saveLocation(result);
        _allPlaces.add(result);
      });
      WidgetsBinding.instance!.addPostFrameCallback((duration) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_allPlaces.length);
        }
      });
    }
  }

  Widget _buildTopBar() => Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _navigateSearch(),
            child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.search)),
          ),
          GestureDetector(
            onTap: () => _navigateSettings(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.settings),
            ),
          )
        ],
      ));
}
