// From envify doc

import 'package:envify/envify.dart';
part 'env.g.dart';

@Envify()
abstract class Env {
  static const openweather = _Env.openweather;
  static const geoapify = _Env.geoapify;
}
