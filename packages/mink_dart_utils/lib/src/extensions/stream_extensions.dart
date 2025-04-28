import 'dart:async';
import 'dart:collection';

import 'package:mink_dart_utils/src/clock.dart';
import 'package:mink_dart_utils/src/mixins/time_bound.dart';

extension MinkUtilsStreamExtension<T> on Stream<T> {
  /// only pick on element at most after [duration]
  Stream<T> pickSample(
    Duration duration, {
    double tolerance = 0,
  }) {
    DateTime? last;

    DateTime current = dartClock.now();

    final toleratedDuration = duration * (1 - tolerance);

    return where((x) {
      current = dartClock.now();
      if (last == null || current.difference(last!) > toleratedDuration) {
        last = current;
        return true;
      } else {
        return false;
      }
    });
  }
}

extension MinkUtilsTimeBoundStreamExtension<T extends TimeBound> on Stream<T> {
  /// only pick on element at most after [duration]
  Stream<T> pickTimeBoundSample(
    Duration duration, {
    double tolerance = 0,

    /// for using synthetic data for testing
    bool allowTimetravel = false,
  }) {
    DateTime? last;
    DateTime current;
    final toleratedDuration = duration * (1 - tolerance);

    return where((x) {
      current = x.time;
      if (last == null ||
          current.difference(last!) > toleratedDuration ||
          (allowTimetravel && current.isBefore(last!))) {
        last = current;
        return true;
      } else {
        return false;
      }
    });
  }

  Stream<T> pickSampleWithRollingOverflowWindow({
    required Duration window,
    required int maxCount,
    Duration? minAcceptanceDelta,
  }) async* {
    final acceptedTimes = Queue<DateTime>();
    await for (final measurement in this) {
      final now = measurement.time;

      // 1) Remove old accepted timestamps that are outside the 1-second window.
      while (acceptedTimes.isNotEmpty &&
          now.difference(acceptedTimes.first) >= window) {
        acceptedTimes.removeFirst();
      }

      // 2) Check how many we have left in the last second.
      if (acceptedTimes.length < maxCount &&
          (acceptedTimes.isEmpty ||
              minAcceptanceDelta == null ||
              now.difference(acceptedTimes.last) >= minAcceptanceDelta)) {
        // We can accept this measurement
        yield measurement;
        acceptedTimes.addLast(now);
      }
      // else -> We discard the measurement (because we already have 5 in the last second).
    }
  }

  /// Returns a stream that buffers events to ensure a minimum time between emissions.
  ///
  /// For example, if the original stream fires multiple events in quick succession,
  /// this method will space them out according to the specified [interval].
  ///
  /// - [interval]: The minimum duration to wait between emitting events.
  /// - [initialDelay]: Optional delay before emitting the first event.
  Stream<T> bufferBetweenEvents(Duration interval,
      {Duration? initialDelay}) async* {
    // Queue to hold events that came in too quickly
    final buffer = Queue<T>();
    bool isProcessingBuffer = false;

    // Create a controller to handle the buffering logic
    final controller = StreamController<T>();

    // Process function that emits events with proper spacing
    Future<void> processBuffer() async {
      if (isProcessingBuffer) return;
      isProcessingBuffer = true;

      // Apply initial delay if specified
      if (initialDelay != null) {
        await Future.delayed(initialDelay ?? Duration.zero);
        initialDelay = null; // Only apply to first event
      }

      while (buffer.isNotEmpty) {
        final event = buffer.removeFirst();
        controller.add(event);

        if (buffer.isNotEmpty) {
          // Wait for the specified interval before emitting the next event
          await Future.delayed(interval);
        }
      }

      isProcessingBuffer = false;
    }

    // Listen to incoming events and buffer them
    final subscription = listen((event) {
      buffer.add(event);
      processBuffer();
    });

    // Forward events from the controller
    await for (final event in controller.stream) {
      yield event;
    }

    // Clean up resources when done
    await subscription.cancel();
    await controller.close();
  }
}
