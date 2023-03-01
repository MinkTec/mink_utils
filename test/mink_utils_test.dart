import 'iterable_test.dart' as iterables;
import 'time_utils_tests.dart' as time;
import 'histogram_test.dart' as histogram;
import 'map_tests.dart' as map;
import 'transform_test.dart' as transform;
import 'curve_fitting_test.dart' as curves;

void main() {
  curves.main();
  iterables.main();
  time.main();
  histogram.main();
  map.main();
  transform.main();
}
