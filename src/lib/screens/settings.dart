import 'package:flutter/material.dart';

import 'package:src/util/preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: const [Settings()],
      ),
    ));
  }
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _imperial = true;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    isImperial().then((value) {
      setState(() {
        _imperial = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildTopBar(), _buildSettings()],
    );
  }

  Widget _buildTopBar() => Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context, _isDirty);
              _isDirty = false;
            },
            child: const Icon(Icons.arrow_back),
          )
        ],
      ));

  Widget _buildSettings() => Column(
        children: [
          SwitchListTile(
            title: Text('Units: ' + (_imperial ? 'imperial' : 'metric')),
            value: _imperial,
            onChanged: (bool value) {
              setState(() {
                _imperial = value;
                _isDirty = true;
                setImperial(value);
              });
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          )
        ],
      );
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [_buildTopbar(context), _buildAbout()],
      ),
    ));
  }

  Widget _buildTopbar(BuildContext context) => Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          )
        ],
      ));

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('About', style: TextStyle(fontSize: 24)),
              Text('Developed by Harry Dang')
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Attributions', style: TextStyle(fontSize: 24)),
              Text('Icons made by iconixar from flaticon.com')
            ],
          ),
        )
      ],
    );
  }
}
