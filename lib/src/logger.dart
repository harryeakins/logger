import 'package:dart_logger/src/filters/debug_filter.dart';
import 'package:dart_logger/src/printers/pretty_printer.dart';
import 'package:dart_logger/src/outputs/console_output.dart';
import 'package:dart_logger/src/log_filter.dart';
import 'package:dart_logger/src/log_printer.dart';
import 'package:dart_logger/src/log_output.dart';

/// [Level]s to control logging output. Logging can be enabled to include all
/// levels above certain [Level].
enum Level {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
  nothing,
}

class LogEvent {
  final Level level;
  final dynamic message;
  final dynamic error;
  final StackTrace stackTrace;

  LogEvent(this.level, this.message, this.error, this.stackTrace);
}

class OutputEvent {
  final Level level;
  final List<String> lines;

  OutputEvent(this.level, this.lines);
}

@Deprecated("Use a custom LogFilter instead")
typedef LogCallback = void Function(LogEvent event);

@Deprecated("Use a custom LogOutput instead")
typedef OutputCallback = void Function(OutputEvent event);

/// Use instances of logger to send log messages to the [LogPrinter].
class Logger {
  /// The current logging level of the app.
  ///
  /// All logs with levels below this level will be omitted.
  static Level level = Level.verbose;

  // NOTE: callbacks are soon to be removed
  static final Set<LogCallback> _logCallbacks = Set();
  // NOTE: callbacks are soon to be removed
  static final Set<OutputCallback> _outputCallbacks = Set();

  final LogFilter _filter;
  final LogPrinter _printer;
  final LogOutput _output;
  bool _active = true;

  /// Create a new instance of Logger.
  ///
  /// You can provide a custom [printer], [filter] and [output]. Otherwise the
  /// defaults: [PrettyPrinter], [DebugFilter] and [ConsoleOutput] will be
  /// used.
  Logger({
    LogFilter filter,
    LogPrinter printer,
    LogOutput output,
    Level level,
  })  : _filter = filter ?? DebugFilter(),
        _printer = printer ?? PrettyPrinter(),
        _output = output ?? ConsoleOutput() {
    _filter.init();
    _filter.level = level ?? Logger.level;
    _printer.init();
    _output.init();
  }

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace stackTrace]) {
    log(Level.verbose, message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace stackTrace]) {
    log(Level.debug, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace stackTrace]) {
    log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace stackTrace]) {
    log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace stackTrace]) {
    log(Level.error, message, error, stackTrace);
  }

  /// Log a message at level [Level.wtf].
  void wtf(dynamic message, [dynamic error, StackTrace stackTrace]) {
    log(Level.wtf, message, error, stackTrace);
  }

  /// Log a message with [level].
  void log(Level level, dynamic message,
      [dynamic error, StackTrace stackTrace]) {
    if (!_active) {
      throw ArgumentError("Logger has already been closed.");
    } else if (error != null && error is StackTrace) {
      throw ArgumentError("Error parameter cannot take a StackTrace!");
    } else if (level == Level.nothing) {
      throw ArgumentError("Log events cannot have Level.nothing");
    }
    var logEvent = LogEvent(level, message, error, stackTrace);
    if (_filter.shouldLog(logEvent)) {
      // NOTE: callbacks are soon to be removed
      for (var callback in _logCallbacks) {
        callback(logEvent);
      }
      var output = _printer.log(logEvent);

      if (output.isNotEmpty) {
        var outputEvent = OutputEvent(level, output);
        // NOTE: callbacks are soon to be removed
        for (var callback in _outputCallbacks) {
          callback(outputEvent);
        }
        _output.output(outputEvent);
      }
    }
  }

  /// Closes the logger and releases all resources.
  void close() {
    _active = false;
    _filter.destroy();
    _printer.destroy();
    _output.destroy();
  }

  /// Register a [LogCallback] which is called for each new [LogEvent].
  @Deprecated("Use a custom LogFilter instead")
  static void addLogListener(LogCallback callback) {
    _logCallbacks.add(callback);
  }

  /// Removes a [LogCallback] which was previously registered.
  ///
  /// Returns wheter the callback was successfully removed.
  @Deprecated("Use a custom LogFilter instead")
  static bool removeLogListener(LogCallback callback) {
    return _logCallbacks.remove(callback);
  }

  /// Register an [OutputCallback] which is called for each new [OutputEvent].
  @Deprecated("Use a custom LogOutput instead")
  static void addOutputListener(OutputCallback callback) {
    _outputCallbacks.add(callback);
  }

  /// Removes a [OutputCallback] which was previously registered.
  ///
  /// Returns wheter the callback was successfully removed.
  @Deprecated("Use a custom LogOutput instead")
  static void removeOutputListener(OutputCallback callback) {
    _outputCallbacks.remove(callback);
  }
}
