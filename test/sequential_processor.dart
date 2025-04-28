import 'dart:async';
import 'package:mink_flutter_utils/mink_flutter_utils.dart';
import 'package:test/test.dart';
import 'package:mink_dart_utils/src/models/sequential_processor.dart';

void main() {
  group('SequentialProcessor', () {
    test('processes events in sequence', () async {
      final processor = SequentialProcessor<int>();
      final results = <int>[];

      processor.listen((data) async {
        // Simulate async work with varying durations
        await Future.delayed(Duration(milliseconds: data * 10));
        results.add(data);
      });

      // Add events in an order that would produce different results
      // if processed in parallel
      processor.add(3); // Would take 30ms
      processor.add(1); // Would take 10ms
      processor.add(2); // Would take 20ms

      await processor.close();

      // Should be processed in the order they were added
      expect(results, equals([3, 1, 2]));
    });

    test('waits for async processing to complete before next event', () async {
      final processor = SequentialProcessor<int>();
      final executionOrder = <String>[];
      final completer = Completer<void>();

      processor.listen((data) async {
        executionOrder.add('start-$data');
        if (data == 1) {
          // Simulate long-running task for first event
          await completer.future;
        }
        executionOrder.add('end-$data');
      });

      processor.add(1);
      processor.add(2);

      // Give time for the first event to start processing
      await Future.delayed(Duration(milliseconds: 10));

      // The processor should have started processing event 1,
      // but not event 2 yet
      expect(executionOrder, equals(['start-1']));

      // Complete the first event's processing
      completer.complete();

      // Wait for all processing to complete
      await processor.close();

      // Verify the complete execution order
      expect(executionOrder, equals(['start-1', 'end-1', 'start-2', 'end-2']));
    });

    test('handles errors in event handlers', () async {
      final results = <String>[];
      final errors = <Object>[];

      final processor = SequentialProcessor<int>()
        ..listen(
          (data) async {
            if (data == 2) {
              throw Exception('Test error');
            }
            results.add('processed-$data');
          },
          onError: (error, _) {
            errors.add(error);
          },
        );

      processor.add(1);
      processor.add(2);
      processor.add(3);

      await processor.close();

      // The first and third events should be processed normally
      expect(results, equals(['processed-1', 'processed-3']));

      // The error from the second event should be captured
      expect(errors.length, equals(1));
      expect(errors.first.toString(), contains('Test error'));
    });

    test('handles explicit error events', () async {
      final processor = SequentialProcessor<int>();
      final errors = <Object>[];

      processor.listen(
        (data) {
          // Normal processing
        },
        onError: (error, _) {
          errors.add(error);
        },
      );

      processor.add(1);
      processor.addError('Test error 1');
      processor.add(2);
      processor.addError('Test error 2');

      await processor.close();

      // Both error events should be processed
      expect(errors, equals(['Test error 1', 'Test error 2']));
    });

    test('close() completes when all events are processed', () async {
      final processor = SequentialProcessor<int>();
      final processed = <int>[];

      processor.listen((data) async {
        await Future.delayed(Duration(milliseconds: 10));
        processed.add(data);
      });

      processor.add(1);
      processor.add(2);

      // Start closing the processor
      final closeFuture = processor.close();

      // Add another event after close (should throw)
      expect(() => processor.add(3), throwsStateError);

      // Wait for close to complete
      await closeFuture;

      // Only the events added before close should be processed
      expect(processed, equals([1, 2]));
    });

    test('multiple listeners receive events sequentially', () async {
      final processor = SequentialProcessor<int>();
      final results1 = <int>[];
      final results2 = <int>[];

      processor.listen((data) async {
        await Future.delayed(Duration(milliseconds: 10));
        results1.add(data);
      });

      processor.listen((data) async {
        await Future.delayed(Duration(milliseconds: 5));
        results2.add(data);
      });

      processor.add(1);
      processor.add(2);

      await processor.close();

      // Both listeners should receive all events
      expect(results1, equals([1, 2]));
      expect(results2, equals([1, 2]));
    });

    test('listener callback can be synchronous', () async {
      final processor = SequentialProcessor<int>();
      final results = <int>[];

      processor.listen((data) {
        // Synchronous callback
        results.add(data);
      });

      processor.add(1);
      processor.add(2);
      processor.add(3);

      await processor.close();

      expect(results, equals([1, 2, 3]));
    });

    test('rejects events after close', () async {
      final processor = SequentialProcessor<int>();

      processor.listen((data) {});

      await processor.close();

      expect(() => processor.addError('error'), throwsStateError);
      expect(() => processor.add(1), throwsStateError);
    });

    test('can be closed multiple times safely', () async {
      final processor = SequentialProcessor<int>();

      processor.listen((data) {});

      final future1 = processor.close();
      final future2 = processor.close();

      await Future.wait([future1, future2]);

      // No assertion needed - test passes if there's no error
    });

    test('handles empty queue on close', () async {
      final processor = SequentialProcessor<int>();

      processor.listen((data) {});

      // Close with empty queue should complete immediately
      final future = processor.close();

      await future.timeout(Duration(milliseconds: 10));
    });
  });

  group('SequentialProcessor with multiple async processors', () {
    test('processes complex async operations in sequence', () async {
      final processor = SequentialProcessor<String>();
      final results = <String>[];
      final operations = <Future>[];

      // Create a bunch of async operations with controlled completers
      final completers = List.generate(5, (i) => Completer<void>());

      processor.listen((data) {
        final index = int.parse(data.split('-')[1]);
        final completer = completers[index - 1];

        final operation = completer.future.then((_) {
          results.add('completed-$data');
        });

        operations.add(operation);
        return operation;
      });

      // Add events in sequence
      processor.add('task-1');
      processor.add('task-2');
      processor.add('task-3');
      processor.add('task-4');
      processor.add('task-5');

      // Complete the operations out of order
      await Future.delayed(Duration(milliseconds: 10));
      completers[2].complete(); // Task 3
      await Future.delayed(Duration(milliseconds: 10));
      completers[0].complete(); // Task 1
      await Future.delayed(Duration(milliseconds: 10));
      completers[4].complete(); // Task 5
      await Future.delayed(Duration(milliseconds: 10));
      completers[1].complete(); // Task 2
      await Future.delayed(Duration(milliseconds: 10));
      completers[3].complete(); // Task 4

      // Wait for all operations to complete
      await Future.wait(operations);
      await processor.close();

      // Results should be in the order of adding, not completion
      expect(
          results,
          equals([
            'completed-task-1',
            'completed-task-2',
            'completed-task-3',
            'completed-task-4',
            'completed-task-5'
          ]));
    });

    test('processes errors during event handling correctly', () async {
      final processor = SequentialProcessor<String>();
      final normalResults = <String>[];
      final errorResults = <String>[];

      processor.listen(
        (data) async {
          await Future.delayed(Duration(milliseconds: 10));
          if (data.contains('error')) {
            throw Exception('Simulated error for $data');
          }
          normalResults.add('processed-$data');
        },
        onError: (error, _) {
          errorResults.add('caught-${error.toString()}');
        },
      );

      processor.add('task-1');
      processor.add('error-task');
      processor.add('task-2');

      await processor.close();

      // Normal tasks should be processed
      expect(normalResults, equals(['processed-task-1', 'processed-task-2']));

      // Errors from tasks should be caught by the error handler
      expect(errorResults.length, equals(1));
      expect(errorResults[0], contains('Simulated error for error-task'));
    });
  });

  test('add and addError return futures that complete when processing is done',
      () async {
    final processor = SequentialProcessor<String>();
    final results = <String>[];

    // Set up a slow processor
    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: 20));
      results.add('processed-$data');
    }, onError: (error, _) async {
      await Future.delayed(Duration(milliseconds: 10));
      results.add('error-$error');
    });

    // Add events without awaiting
    final future1 = processor.add('event1');
    final future2 = processor.add('event2');
    final future3 = processor.addError('error1');

    // Test that results are empty before futures complete
    expect(results, isEmpty);

    // Now await the first future
    await future1;

    // After future1 completes, only the first event should be processed
    expect(results, equals(['processed-event1']));

    // Await the second future
    await future2;

    // Now first and second events should be processed
    expect(results, equals(['processed-event1', 'processed-event2']));

    // Await the error event
    await future3;

    // All events should be processed
    expect(results,
        equals(['processed-event1', 'processed-event2', 'error-error1']));

    // Close the processor
    await processor.close();
  });

  test('add returns future that completes even if listener throws error',
      () async {
    final processor = SequentialProcessor<String>();
    final results = <String>[];
    final errors = <Object>[];

    // Set up a processor where some events throw errors
    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: 10));
      if (data == 'error-event') {
        throw Exception('Test error');
      }
      results.add('processed-$data');
    }, onError: (error, _) {
      errors.add(error);
    });

    // Add events
    final normalFuture = processor.add('normal-event');
    final errorFuture = processor.add('error-event');
    final lastFuture = processor.add('last-event');

    // Both futures should complete even though one throws an error
    await normalFuture;
    expect(results, equals(['processed-normal-event']));

    await errorFuture;
    expect(errors.length, equals(1));
    expect(errors.first.toString(), contains('Test error'));

    await lastFuture;
    expect(results, equals(['processed-normal-event', 'processed-last-event']));

    await processor.close();
  });

  test('multiple concurrent operations can track their own completion',
      () async {
    final processor = SequentialProcessor<int>();
    final completedEvents = <int>[];

    processor.listen((data) async {
      await Future.delayed(
          Duration(milliseconds: data * 10)); // Longer delay for higher numbers
      completedEvents.add(data);
    });

    // Start multiple operations
    final futures = await Future.wait([
      processor.add(3).then((_) => 3), // Will take 30ms
      processor.add(1).then((_) => 1), // Will take 10ms
      processor.add(2).then((_) => 2), // Will take 20ms
    ]);

    // The futures should complete in sequential order
    expect(futures, equals([3, 1, 2]));

    // But the events should be processed in the order they were added
    expect(completedEvents, equals([3, 1, 2]));

    await processor.close();
  });

  test(
      'events are processed sequentially even with slow listeners and awaited adds',
      () async {
    final processor = SequentialProcessor<String>();
    final results = <String>[];

    processor.listen((data) async {
      // Simulate varying processing times
      final delay = data == 'slow' ? 50 : 10;
      await Future.delayed(Duration(milliseconds: delay));
      results.add(data);
    });

    // Add events and await each one before adding the next
    await processor.add('first');
    await processor.add('slow');
    await processor.add('last');

    // Events should be processed in order
    expect(results, equals(['first', 'slow', 'last']));

    await processor.close();
  });

  test('error events wait for their error handlers to complete', () async {
    final processor = SequentialProcessor<String>();
    final timeline = <String>[];
    final completer = Completer<void>();

    // Set up a processor with a slow error handler
    processor.listen((data) {
      timeline.add('data-$data');
    }, onError: (error, _) async {
      timeline.add('error-started');
      await completer.future;
      timeline.add('error-completed');
    });

    // Add a normal event
    await processor.add('first');

    // Add an error and don't await it yet
    processor.addError('test-error');

    // Give time for error processing to start
    await Future.delayed(Duration(milliseconds: 10));

    // Add another event but don't await
    final lastFuture = processor.add('last');

    // At this point, error processing should have started but not completed
    expect(timeline, equals(['data-first', 'error-started']));

    // Complete the error handler
    completer.complete();

    // Wait for the last event
    await lastFuture;

    // All events should be processed in order
    expect(
        timeline,
        equals(
            ['data-first', 'error-started', 'error-completed', 'data-last']));

    await processor.close();
  });

  test('whenAllEventsProcessed completes when all events are processed',
      () async {
    final processor = SequentialProcessor<String>();

    // Initially, whenAllEventsProcessed should be completed
    await processor.whenAllEventsProcessed.timeout(Duration(milliseconds: 10));

    // Add some events
    final event1Future = processor.add('event1');
    final event2Future = processor.add('event2');

    // whenAllEventsProcessed should not be completed yet
    bool allCompleted = false;

    processor.whenAllEventsProcessed.then((_) => allCompleted = true);

    //await Future.delayed(Duration(milliseconds: 10));
    expect(allCompleted, isFalse);

    // Complete event1
    await event1Future;

    // Still not all completed
    expect(allCompleted, isFalse);

    // Complete event2
    await event2Future;

    // Now all events should be processed
    await Future.delayed(Duration(milliseconds: 10));
    expect(allCompleted, isTrue);
  });

  test('whenAllEventsProcessed resets when new events are added', () async {
    final processor = SequentialProcessor<String>();
    final results = <String>[];

    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: 10));
      results.add(data);
    });

    // Add and process first batch
    await processor.add('event1');
    await processor.add('event2');

    // whenAllEventsProcessed should now be completed
    bool firstBatchCompleted = false;
    processor.whenAllEventsProcessed.then((_) => firstBatchCompleted = true);
    await Future.delayed(Duration(milliseconds: 5));
    expect(firstBatchCompleted, isTrue);

    // Add more events
    final event3Future = processor.add('event3');

    // A new whenAllEventsProcessed future should not be completed
    bool secondBatchCompleted = false;
    processor.whenAllEventsProcessed.then((_) => secondBatchCompleted = true);
    await Future.delayed(Duration(milliseconds: 5));
    expect(secondBatchCompleted, isFalse);

    // Complete all events
    await event3Future;

    // Now all events should be complete
    await Future.delayed(Duration(milliseconds: 5));
    expect(secondBatchCompleted, isTrue);
    expect(results, equals(['event1', 'event2', 'event3']));
  });

  test('whenAllEventsProcessed works correctly with errors', () async {
    final processor = SequentialProcessor<String>();
    final errors = <Object>[];

    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: 10));
      if (data.contains('error')) {
        throw Exception('Test error in $data');
      }
    }, onError: (error, _) {
      errors.add(error);
    });

    // Add mix of normal and error events
    final event1Future = processor.add('normal1');
    final event2Future = processor.addError('explicit error');
    final event3Future = processor.add('error-event');
    final event4Future = processor.add('normal2');

    // whenAllEventsProcessed should not be completed yet
    bool allCompleted = false;
    processor.whenAllEventsProcessed.then((_) => allCompleted = true);

    await Future.delayed(Duration(milliseconds: 10));
    expect(allCompleted, isFalse);

    // Wait for all events to complete
    await Future.wait([event1Future, event2Future, event3Future, event4Future]);

    // Now all events should be processed, including errors
    await Future.delayed(Duration(milliseconds: 10));
    expect(allCompleted, isTrue);
    expect(errors.length, 2); // One explicit error, one thrown error
  });

  test('whenAllEventsProcessed completes immediately when queue is empty',
      () async {
    final processor = SequentialProcessor<String>();

    // Add and process events
    await processor.add('event1');
    await processor.add('event2');

    // When queue is empty, whenAllEventsProcessed should complete immediately
    final future = processor.whenAllEventsProcessed;
    try {
      await future;
      expect(true, true);
    } catch (e) {
      expect(true, false);
    }
  });

  test('whenAllEventsProcessed waits for all events when processor is closed',
      () async {
    final processor = SequentialProcessor<String>();
    final results = <String>[];

    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: data == 'slow' ? 50 : 10));
      results.add(data);
    });

    // Add events including a slow one
    processor.add('fast1');
    processor.add('slow');
    processor.add('fast2');

    // Start closing (shouldn't complete until all events are processed)
    final closeFuture = processor.close();

    // Check if both futures complete together
    bool closeFutureCompleted = false;
    bool allEventsCompleted = false;

    closeFuture.then((_) => closeFutureCompleted = true);
    processor.whenAllEventsProcessed.then((_) => allEventsCompleted = true);

    // Neither should be completed immediately
    await Future.delayed(Duration(milliseconds: 10));
    expect(closeFutureCompleted, isFalse);
    expect(allEventsCompleted, isFalse);

    // Both should complete after the slow event finishes
    await Future.delayed(Duration(milliseconds: 100));
    expect(closeFutureCompleted, isTrue);
    expect(allEventsCompleted, isTrue);
    expect(results, equals(['fast1', 'slow', 'fast2']));
  });

  test(
      'complex workflow with mixing add, whenAllEventsProcessed and error handling',
      () async {
    final processor = SequentialProcessor<String>();
    final results = <String>[];
    final errors = <String>[];

    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: 10));
      if (data.contains('error')) {
        throw Exception('Error in $data');
      }
      results.add('processed-$data');
    }, onError: (error, _) {
      errors.add(error.toString());
    });

    // First batch
    await processor.add('batch1-item1');
    await processor.add('batch1-item2');

    // Verify first batch is complete

    try {
      await processor.whenAllEventsProcessed
          .timeout(Duration(milliseconds: 10));
      expect(true, true);
    } catch (e) {
      expect(true, false);
    }
    expect(
        results, equals(['processed-batch1-item1', 'processed-batch1-item2']));

    // Second batch with errors
    processor.add('batch2-item1');
    processor.add('batch2-error');
    processor.add('batch2-item2');

    // Wait for second batch
    await processor.whenAllEventsProcessed;

    expect(
        results,
        equals([
          'processed-batch1-item1',
          'processed-batch1-item2',
          'processed-batch2-item1',
          'processed-batch2-item2'
        ]));
    expect(errors.length, 1);
    expect(errors[0], contains('Error in batch2-error'));

    // Third batch - add without awaiting individual events
    final batch3Futures = [
      processor.add('batch3-item1'),
      processor.add('batch3-item2'),
      processor.addError('batch3-explicit-error')
    ];

    // Wait for all batch 3 events to complete using whenAllEventsProcessed
    await processor.whenAllEventsProcessed;

    // Ensure all futures completed
    await Future.wait(batch3Futures);

    // Verify final state
    expect(
        results,
        equals([
          'processed-batch1-item1',
          'processed-batch1-item2',
          'processed-batch2-item1',
          'processed-batch2-item2',
          'processed-batch3-item1',
          'processed-batch3-item2'
        ]));
    expect(errors.length, 2); // One from batch2 and one explicit from batch3

    // Close the processor
    await processor.close();
  });

  test('queued events count is accurate', () async {
    final processor = SequentialProcessor<String>();

    // Initially queue is empty
    expect(processor.queueLength, equals(0));

    // Add events without awaiting completion
    processor.listen((data) async {
      await Future.delayed(Duration(milliseconds: 20));
    });

    processor.add('event1');
    expect(processor.queueLength, equals(0)); // Immediately starts processing

    processor.add('event2');
    processor.add('event3');
    expect(processor.queueLength, equals(2)); // Two events queued

    // Wait for all to complete
    await processor.whenAllEventsProcessed;
    expect(processor.queueLength, equals(0)); // Queue should be empty again
  });

  test('processing takes at least the expected time', () async {
    final processor = SequentialProcessor<int>();
    final results = <int>[];

    final int multiple = 10;

    // Set up a processor with known processing times
    processor.listen((data) async {
      final duration = Duration(milliseconds: data * multiple);
      await Future.delayed(duration);
      results.add(data);
    });

    // Record start time
    final startTime = DateTime.now();

    final values = [5, 10];
    // Add events with specific durations
    for (var value in values) {
      await processor.add(value);
    }

    // Record end time
    final endTime = DateTime.now();
    final totalDuration = endTime.difference(startTime);

    // Total should be at least the sum of individual durations
    expect(totalDuration.inMilliseconds,
        greaterThanOrEqualTo(values.sum * multiple));
    expect(results, equals([5, 10]));

    // Add another batch with parallel processing for comparison
    final parallelStart = DateTime.now();
    final parallelProcessor = SequentialProcessor<int>();
    final parallelResults = <int>[];

    // Create a processor that processes events in parallel
    parallelProcessor.listen((data) async {
      final duration = Duration(milliseconds: data * multiple);
      await Future.delayed(duration);
      parallelResults.add(data);
    });

    // Add events without awaiting each individually
    parallelProcessor.add(5);
    parallelProcessor.add(10);

    // Wait for all to complete
    await parallelProcessor.whenAllEventsProcessed;

    final parallelEnd = DateTime.now();
    final parallelDuration = parallelEnd.difference(parallelStart);

    // Sequential processor should take longer than parallel approach
    // since we awaited each add individually in the sequential case
    expect(parallelDuration.inMilliseconds,
        greaterThanOrEqualTo(totalDuration.inMilliseconds));
    expect(parallelResults, equals([5, 10]));
  });
}
