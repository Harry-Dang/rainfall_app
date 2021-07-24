import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isImperial() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getBool('imperial') == null) {
    preferences.setBool('imperial', true);
    return true;
  }
  return preferences.getBool('imperial')!;
}

void setImperial(bool value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool('imperial', value);
}
