import 'package:http/http.dart' as http;
import 'package:src/env/env.dart';

class ForecastData {
  Future<http.Response> fetchData() {
    return http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=38.328732&lon=-85.764771&exclude={part}&appid=' +
            Env.openweather));
  }
}
