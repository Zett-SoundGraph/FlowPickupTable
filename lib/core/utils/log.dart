import 'package:flutter/foundation.dart';

/// Centralized logging utility for all apps.
/// Use Log.d / Log.e / Log.w / Log.i instead of debugPrint directly.
class Log {
  /// Logs a debug message.
  static void d(String tag, String message) {
    debugPrint('[$tag] $message');
  }

  /// Logs an error message.
  static void e(String tag, String message) {
    debugPrint('[$tag] ERROR: $message');
  }

  /// Logs a warning message.
  static void w(String tag, String message) {
    debugPrint('[$tag] WARN: $message');
  }

  /// Logs an info message.
  static void i(String tag, String message) {
    debugPrint('[$tag] INFO: $message');
  }
}
