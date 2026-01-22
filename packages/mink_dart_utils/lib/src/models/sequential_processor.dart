import 'dart:async';
import 'dart:collection';

// Helper class to distinguish data and error events in the queue
class SequentialEvent<T> {
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isError;
  final Completer<void> completer; // Completer to track when event is processed

  SequentialEvent.data(this.data)
      : error = null,
        stackTrace = null,
        isError = false,
        completer = Completer<void>();

  SequentialEvent.error(this.error, this.stackTrace)
      : data = null,
        isError = true,
        completer = Completer<void>();

  @override
  String toString() {
    if (isError) {
      return 'SequentialEvent.error(error: $error, stackTrace: $stackTrace)';
    } else {
      return 'SequentialEvent.data(data: $data)';
    }
  }
}

class _CaughtError {
  final Object error;
  final StackTrace stackTrace;
  _CaughtError(this.error, this.stackTrace);
}

/// A class that processes events sequentially.
///
/// When an event (data or error) is added using [add] or [addError],
/// it's queued. The processor ensures that only one event is processed at a
/// time. It iterates through registered listeners for the event type.
/// If a listener returns a [Future], the processor waits for that future
/// to complete before calling the next listener or processing the next event
/// in the queue.
class SequentialProcessor<T> {
  final Queue<SequentialEvent<T>> _eventQueue = Queue<SequentialEvent<T>>();
  final List<FutureOr<void> Function(T)> _dataListeners = [];
  final List<FutureOr<void> Function(Object, StackTrace?)> _errorListeners = [];

  bool _isProcessing = false;
  bool _isClosed = false;
  bool _isClosingRequested = false; // Track when closing is requested
  Completer<void>? _closeCompleter;
  Completer<void>? _processingCompleter; // Tracks current event processing

  // Completer for tracking when all events are processed
  Completer<void> _allEventsProcessedCompleter = Completer<void>()..complete();

  int get queueLength => _eventQueue.length;

  /// Returns true if the processor has been closed.
  bool get isClosed => _isClosed;

  /// Returns a future that completes when all currently queued events
  /// have been processed.
  Future<void> get whenAllEventsProcessed =>
      _allEventsProcessedCompleter.future;

  /// Registers listeners for data and error events.
  ///
  /// [onData] is called for events added via [add].
  /// [onError] is called for events added via [addError].
  /// Both function types can be synchronous or return a Future.
  void listen(
    FutureOr<void> Function(T data)? onData, {
    Function? onError, // Accepts various Function signatures
  }) {
    if (_isClosed) {
      throw StateError('Processor has been closed');
    }
    if (onData != null) {
      _dataListeners.add(onData);
    }
    if (onError != null) {
      // Adapt common function signatures for error handling
      if (onError is FutureOr<void> Function(Object, StackTrace?)) {
        _errorListeners.add(onError);
      } else if (onError is FutureOr<void> Function(Object)) {
        // Adapt signature if StackTrace is omitted by user
        _errorListeners.add((err, _) => onError(err));
      } else {
        // Could add more specific checks or throw ArgumentError
        print(
            "Warning: Unsupported onError signature. Expected Function(Object) or Function(Object, StackTrace).");
      }
    }
  }

  /// Adds a data event to the processing queue.
  ///
  /// Throws a [StateError] if the processor is closed.
  /// Returns a [Future] that completes when the event is fully processed.
  Future<void> add(T data) {
    if (_isClosed) {
      throw StateError('Cannot add event to closed processor');
    }

    // Reset the all events processed completer if it was already completed
    if (_allEventsProcessedCompleter.isCompleted) {
      _allEventsProcessedCompleter = Completer<void>();
    }

    final event = SequentialEvent<T>.data(data);
    _eventQueue.add(event);
    _tryProcessNext();
    return event.completer.future;
  }

  /// Adds an error event to the processing queue.
  ///
  /// Throws a [StateError] if the processor is closed.
  /// Returns a [Future] that completes when the error is fully processed.
  Future<void> addError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Cannot add error to closed processor');
    }

    // Reset the all events processed completer if it was already completed
    if (_allEventsProcessedCompleter.isCompleted) {
      _allEventsProcessedCompleter = Completer<void>();
    }

    // Always add error events to the queue - even during closing
    final event = SequentialEvent<T>.error(error, stackTrace);
    _eventQueue.add(event);
    _tryProcessNext();
    return event.completer.future;
  }

  /// Signals that no more events will be added.
  ///
  /// Returns a [Future] that completes when all currently queued events
  /// have been processed.
  Future<void> close() {
    if (!_isClosed) {
      _isClosingRequested = true; // Set flag to indicate closing was requested
      _closeCompleter = Completer<void>();

      // Set isClosed to prevent new external events being added
      _isClosed = true;

      // If not processing and queue is empty, complete immediately.
      if (!_isProcessing && _eventQueue.isEmpty) {
        _closeCompleter!.complete();
      }
      // Otherwise, completion happens in _tryProcessNext when the queue is empty
    }
    return _closeCompleter?.future ?? Future.value();
  }

  // Internal method to start processing if not already busy.
  void _tryProcessNext() {
    if (_isProcessing || _eventQueue.isEmpty) {
      // If queue is empty and not processing, complete the all events processed completer
      if (_eventQueue.isEmpty &&
          !_isProcessing &&
          !_allEventsProcessedCompleter.isCompleted) {
        _allEventsProcessedCompleter.complete();
      }

      // If closing was requested and queue becomes empty, complete the close future.
      if (_isClosingRequested &&
          _eventQueue.isEmpty &&
          !_isProcessing && // Only complete if not processing
          _closeCompleter != null &&
          !_closeCompleter!.isCompleted) {
        _closeCompleter!.complete();
      }
      return;
    }

    _isProcessing = true;
    _processingCompleter = Completer<void>(); // To track this specific event

    // Get the next event
    final event = _eventQueue.removeFirst();

    // Process the event asynchronously
    _processEvent(event).whenComplete(() {
      _isProcessing = false;
      _processingCompleter?.complete(); // Mark this event as done
      _processingCompleter = null;

      // Complete the event completer to signal the event is processed
      event.completer.complete();

      // Trigger processing for the next item if available
      _tryProcessNext();
    });
  }

  // Helper to handle an error through error listeners
  Future<void> _handleError(Object error, StackTrace? stackTrace) async {
    if (_errorListeners.isEmpty) {
      print('No error listeners registered!');
      return;
    }

    List<Future> errorFutures = [];

    // Call all error listeners, collect futures
    for (final listener in List.from(_errorListeners)) {
      try {
        final result = listener(error, stackTrace);
        if (result is Future) {
          errorFutures.add(result);
        }
      } catch (e, s) {
        print('Error in error listener: $e\n$s');
        // We don't propagate errors from error listeners to avoid infinite loops
      }
    }

    // Wait for all error handler futures to complete
    if (errorFutures.isNotEmpty) {
      await Future.wait(errorFutures);
    }
  }

  // Processes a single event (data or error) by calling relevant listeners sequentially.
  Future<void> _processEvent(SequentialEvent<T> event) async {
    if (event.isError) {
      // This is an error event - call error listeners directly
      await _handleError(event.error!, event.stackTrace);
    } else {
      // Call all data listeners for this event
      List<Future> pendingOperations = [];
      List<_CaughtError> caughtErrors = [];

      // Track errors that occur during data listener processing

      // Process through all data listeners
      for (final listener in List.from(_dataListeners)) {
        try {
          final result = listener(event.data as T);
          if (result is Future) {
            // For async listeners, wrap in try-catch to handle async errors
            pendingOperations.add(result.catchError((e, s) {
              caughtErrors.add(_CaughtError(e, s));
              return null; // We've handled the error
            }));
          }
        } catch (e, s) {
          caughtErrors.add(_CaughtError(e, s));
        }
      }

      // Wait for all pending operations to complete
      if (pendingOperations.isNotEmpty) {
        await Future.wait(pendingOperations);
      }

      // Process any errors that were caught
      for (final caught in caughtErrors) {
        await _handleError(caught.error, caught.stackTrace);
      }
    }
  }
}
