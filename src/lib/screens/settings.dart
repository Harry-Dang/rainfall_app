import 'package:flutter/material.dart';

import 'package:src/util/preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: const [TopBar(), Settings()],
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
      children: [
        SwitchListTile(
          title: Text('Units: ' + (_imperial ? 'imperial' : 'metric')),
          value: _imperial,
          onChanged: (bool value) {
            setState(() {
              _imperial = value;
              setImperial(value);
            });
          },
        ),
        const Text('test')
      ],
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
