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
import 'element_reduction.dart' as element_reduction;
import 'timebound_extensions.dart' as timebound_extensions;
import 'parallel_async_task_queue.dart' as parallel_async_task_queue;

void main() {
  parallel_async_task_queue.main();
  timebound_extensions.main();
  element_reduction.main();
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
