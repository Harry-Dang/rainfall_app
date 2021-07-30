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

  final List<ForecastData> _allForecastData = [];

  final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  int _pageIndex = 0;

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
            List<Widget> pages = [const Icon(Icons.gps_off)];
            for (int i = 0; i < _allPlaces.length; i++) {
              pages.add(const Icon(Icons.circle));
            }
            return Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _allPlaces.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    _allForecastData.add(ForecastData());
                    return ForecastPage(forecastData: _allForecastData[index]);
                  } else {
                    _allForecastData
                        .add(ForecastData(place: _allPlaces[index - 1]));
                    return ForecastPage(forecastData: _allForecastData[index]);
                  }
                },
                onPageChanged: (int page) {
                  setState(() {
                    _pageIndex = page;
                  });
                },
              ),
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

  Widget _buildTopBar() {
    List<Widget> pages = [];
    pages.add(Icon(_pageIndex == 0 ? Icons.gps_fixed : Icons.gps_not_fixed,
        color: Colors.grey[700], size: 18));
    for (int i = 0; i < _allPlaces.length; i++) {
      pages.add(Icon(
          _pageIndex == i + 1 ? Icons.circle : Icons.radio_button_unchecked,
          color: Colors.grey[700],
          size: 18));
    }
    return Container(
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
            Row(children: pages),
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
}
