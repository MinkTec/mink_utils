import 'dart:collection';
import 'dart:isolate';

import 'package:mink_dart_utils/src/extensions/datetime_list_extensions.dart';
import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';
import 'package:mink_dart_utils/src/extensions/nested_iterable_extensions.dart';


extension ParallelUtils<T> on List<T> {
  Future<List<S>> parIter<S>(S Function(T) function,
      {int isolatesCount = 4}) async {

    List<S> Function() futureCallbackGenerator(Iterable<T> t) =>
        () => [for (var x in t) function(x)];

    final futures =
        nchunks(isolatesCount).map(futureCallbackGenerator).map(Isolate.run);

    return Future.wait(futures).then((x) => x.flatten().toList());
  }
}
