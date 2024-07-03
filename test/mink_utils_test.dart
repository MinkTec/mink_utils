import 'iterable_test.dart' as iterables;
import 'time_utils_test.dart' as time;
import 'histogram_test.dart' as histogram;
import 'map_tests.dart' as map;
import 'transform_test.dart' as transform;
import 'curve_fitting_test.dart' as curves;
import 'time_bound_methods.dart' as timebound;
import 'lock_test.dart' as lock;
import 'semver.dart' as semver;
import 'timeout_buffer.dart' as timeout_buffer;
import 'logic.dart' as logic;

void main() {
  logic.main();
  timeout_buffer.main();
  curves.main();
  iterables.main();
  time.main();
  histogram.main();
  map.main();
  transform.main();
  timebound.main();
  lock.main();
  semver.main();
}
