import 'package:dart_logger/src/logger.dart';
import 'package:dart_logger/src/log_filter.dart';

/// Prints all logs with `level >= Logger.level` even in production.
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level.index;
  }
}
