import 'package:flutter/material.dart';

import 'package:src/search/search.dart';

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
  final TextEditingController _searchController = TextEditingController();

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
                if (_searchController.text.isNotEmpty) {
                  _results = await search(_searchController.text);
                } else {
                  _results = [];
                }
                setState(() {});
              },
              onSubmitted: (String value) async {
                FocusScope.of(context).unfocus();
                if (value.isNotEmpty) {
                  _results = await search(value);
                } else {
                  _results = [];
                }
                setState(() {});
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
                    Navigator.pop(context, _results[index]);
                  },
                  child: ListTile(
                    title: Text(_results[index].name),
                  ),
                );
              }));
    } else {
      return Container();
    }
  }
}
