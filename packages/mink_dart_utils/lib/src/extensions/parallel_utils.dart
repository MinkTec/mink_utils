import 'dart:isolate';

import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';
import 'package:mink_dart_utils/src/extensions/nested_iterable_extensions.dart';

extension ParallelUtils<T> on List<T> {
  Future<List<S>> parIter<S>(S Function(T) function,
      {int isolatesCount = 4}) async {
    List<S> Function() futureCallbackGenerator(Iterable<T> t) =>
        () => [for (var x in t) function(x)];

    // Check if isolates are supported (native platforms)
    final bool supportsIsolates = _isIsolateSupported();

    if (supportsIsolates) {
      // Use isolates for native platforms
      final futures =
          nchunks(isolatesCount).map(futureCallbackGenerator).map(Isolate.run);
      return Future.wait(futures).then((x) => x.flatten().toList());
    } else {
      // Use regular futures for web platform
      final futures = nchunks(isolatesCount)
          .map(futureCallbackGenerator)
          .map((callback) => Future(() => callback()));
      return Future.wait(futures).then((x) => x.flatten().toList());
    }
  }

  bool _isIsolateSupported() {
    try {
      // Try to access Isolate.current - this will throw on web
      Isolate.current;
      return true;
    } catch (e) {
      return false;
    }
  }
}
