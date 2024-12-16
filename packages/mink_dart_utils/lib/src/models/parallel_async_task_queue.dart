import 'dart:async';

import 'package:mink_dart_utils/src/extensions/iterable_extensions.dart';

typedef OnError<S, T> = Future<S> Function(dynamic e, (int, T) value);

class ParallelAsyncTaskQueue<Output, Input> {
  final List<Input> input;
  final Future<Output> Function(Input input) map;
  final OnError<Output, Input>? onError;
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

  ParallelAsyncTaskQueue<Output, Input> copyWith({
    List<Input>? input,
    Future<Output> Function(Input input)? map,
    OnError<Output, Input>? onError,
    void Function(int current, int total)? progressCallback,
    int? maxParallel,
  }) {
    return ParallelAsyncTaskQueue<Output, Input>(
      input: input ?? this.input,
      map: map ?? this.map,
      onError: onError ?? this.onError,
      progressCallback: progressCallback ?? this.progressCallback,
      maxParallel: maxParallel ?? this.maxParallel,
    );
  }

  Future<List<Output>> run() async {
    if (input.isEmpty) {
      return [];
    }

    int counter = 0;
    int doneCounter = 0;
    final Completer<List<Output>> completer = Completer();
    final enumerated = input.enumerate();
    final List<Output?> results = List<Output?>.filled(input.length, null);

    Future<void> executor((int, Input) x) async {
      counter++;
      await map(x.$2).then((result) {
        if (counter < input.length) {
          executor((counter, input[counter]));
        }
        doneCounter++;
        results[x.$1] = result;
        progressCallback?.call(doneCounter, input.length);
        if (doneCounter == input.length) {
          return completer.complete(results.cast<Output>());
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
