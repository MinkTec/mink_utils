import 'dart:async';


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
    final List<Output?> results = List<Output?>.filled(input.length, null);
    final completer = Completer<List<Output>>();
    int nextIndex = 0;
    int doneCounter = 0;
    int running = 0;

    void maybeComplete() {
      if (doneCounter == input.length && !completer.isCompleted) {
        completer.complete(results.cast<Output>());
      }
    }

    void startNext() {
      if (nextIndex >= input.length) {
        maybeComplete();
        return;
      }
      final current = nextIndex++;
      final value = input[current];
      running++;
  map(value).then((out) => out, onError: (e) async {
        if (onError != null) {
          try {
            return await onError!(e, (current, value));
          } catch (_) {
    throw e;
          }
        }
    throw e;
      }).then((output) {
        results[current] = output;
      }).catchError((_) {
        // leave result null on failure without handler
      }).whenComplete(() {
        running--;
        doneCounter++;
        progressCallback?.call(doneCounter, input.length);
        if (nextIndex < input.length) {
          startNext();
        } else if (running == 0) {
          maybeComplete();
        }
      });
    }

    final initial = maxParallel < input.length ? maxParallel : input.length;
    for (int i = 0; i < initial; i++) {
      startNext();
    }

    return completer.future;
  }
}
