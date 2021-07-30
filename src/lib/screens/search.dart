import 'package:flutter/material.dart';
import 'package:src/forecast/forecast.dart';
import 'package:src/screens/forecast_page.dart';

import 'package:src/search/search.dart';
import 'package:src/util/save.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: SearchBody()),
    );
  }
}

class SearchBody extends StatefulWidget {
  const SearchBody({Key? key}) : super(key: key);

  @override
  _SearchBodyState createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  List<Places> _results = [];
  late List<Places> _savedPlaces;
  final TextEditingController _searchController = TextEditingController();

  void _getSavedPlaces() async {
    _savedPlaces = await getPlaces();
  }

  @override
  void initState() {
    super.initState();
    _getSavedPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildTopBar(), _buildSearchBar(), _buildResults()],
    );
  }

  Widget _buildTopBar() => Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context, false);
            },
            child: const Icon(Icons.arrow_back),
          )
        ],
      ));

  Widget _buildSearchBar() => Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.gps_fixed)),
          ),
          Flexible(
            child: TextField(
              controller: _searchController,
              maxLines: 1,
              onEditingComplete: () async {
                FocusScope.of(context).unfocus();
                List<Places> results = [];
                if (_searchController.text.isNotEmpty) {
                  results = await search(_searchController.text);
                } else {
                  results = [];
                }
                setState(() {
                  _results = results;
                });
              },
              onSubmitted: (String value) async {
                FocusScope.of(context).unfocus();
                List<Places> results = [];
                if (value.isNotEmpty) {
                  results = await search(value);
                } else {
                  results = [];
                }
                setState(() {
                  _results = results;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Search'),
            ),
          ),
          GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (_searchController.text.isNotEmpty) {
                  _results = await search(_searchController.text);
                } else {
                  _results = [];
                }
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.search),
              ))
        ],
      ));

  Widget _buildResults() {
    if (_results.isNotEmpty) {
      return Expanded(
          child: ListView.builder(
              shrinkWrap: _results.isNotEmpty,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                _buildTemporaryPage(context, _results[index])));
                  },
                  child: ListTile(
                    title: Text(_results[index].name),
                    trailing: alreadySaved(_savedPlaces, _results[index])
                        ? Container(
                            width: 1,
                          )
                        : GestureDetector(
                            onTap: () {
                              try {
                                saveLocation(_results[index]);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                              Navigator.pop(context, _results[index]);
                            },
                            child: const Icon(Icons.add),
                          ),
                  ),
                );
              }));
    } else {
      return Container();
    }
  }

  Widget _buildTemporaryPage(BuildContext context, Places place) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Container(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.arrow_back))),
                    GestureDetector(
                      onTap: () {
                        try {
                          saveLocation(place);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }
                        Navigator.pop(context);
                        Navigator.pop(context, place);
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.add)),
                    )
                  ],
                )),
            // body
            Expanded(
                child: ForecastPage(forecastData: ForecastData(place: place)))
          ],
        ),
      ),
    );
  }
}
