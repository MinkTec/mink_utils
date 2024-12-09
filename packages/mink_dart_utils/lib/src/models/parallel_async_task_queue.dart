import 'dart:async';

import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';

typedef OnError<S, T> = Future<S> Function(dynamic e, (int, T) value);

class ParallelAsyncTaskQueue<S, T> {
  final List<T> input;
  final Future<S> Function(T input) map;
  final OnError<S, T>? onError;
  final void Function(int current, int total)? progressCallback;
  final int maxParallel;

  ParallelAsyncTaskQueue({
    required this.input,
    required this.map,
    this.maxParallel = 50,
    this.onError,
    this.progressCallback,
  }) {
    assert(maxParallel > 0);
  }

  ParallelAsyncTaskQueue<S, T> copyWith({
    List<T>? input,
    Future<S> Function(T input)? map,
    OnError<S, T>? onError,
    void Function(int current, int total)? progressCallback,
    int? maxParallel,
  }) {
    return ParallelAsyncTaskQueue<S, T>(
      input: input ?? this.input,
      map: map ?? this.map,
      onError: onError ?? this.onError,
      progressCallback: progressCallback ?? this.progressCallback,
      maxParallel: maxParallel ?? this.maxParallel,
    );
  }

  Future<List<S>> run() async {
    int counter = 0;
    int doneCounter = 0;
    final Completer<List<S>> completer = Completer();
    final enumerated = input.enumerate();
    final List<S?> results = List<S?>.filled(input.length, null);

    Future<void> executor((int, T) x) async {
      counter++;
      progressCallback?.call(counter, input.length);
      await map(x.$2).then((result) {
        if (counter < input.length) {
          executor((counter, input[counter]));
        }
        doneCounter++;
        results[x.$1] = result;
        progressCallback?.call(doneCounter, input.length);
        if (doneCounter == input.length) {
          return completer.complete(results.cast<S>());
        }
      }, onError: (e) async {
        if (onError != null) {
          results[x.$1] = await onError!(e, x);
          doneCounter++;

          if (counter < input.length) {
            executor((counter, input[counter]));
          }
        } else {
          throw e;
        }
      });
    }

    enumerated.take(maxParallel).forEach(executor);

    return completer.future;
  }
}
