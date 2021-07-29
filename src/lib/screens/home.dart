import 'package:flutter/material.dart';

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
  List<Places>? _allPlaces;

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
            for (int i = 0; i <= _allPlaces!.length; i++) {
              if (i == 0) {
                _pages.add(ForecastPage(id: i, load: true));
              } else {
                _pages.add(ForecastPage(
                    id: i, place: _allPlaces![i - 1], load: false));
              }
            }
            return Expanded(
                child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {});
              },
              children: _pages,
            ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    ]);
  }

  void _navigateSettings() async {
    dynamic result = await Navigator.pushNamed(context, '/settings');
    // _pages[_pageController.page!.toInt()].refresh(result ?? false);
    if (result ?? false) {
      setState(() {});
    }
  }

  void _navigateSearch() async {
    dynamic result = await Navigator.pushNamed(context, '/search');
    if (result == null || result is Places) {
      // _place = result;
      // _refresh(_isRefreshNeeded());
      setState(() {});
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
