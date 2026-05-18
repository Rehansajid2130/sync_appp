import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Centralized logging utility for the application.
/// 
/// Instead of using `print()`, use `AppLogger` to ensure logs are formatted properly
/// and can be easily disabled in production builds.
class AppLogger {
  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('VERBOSE', message, error, stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARN', message, error, stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('FATAL', message, error, stackTrace);
  }

  static void _log(String level, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      final logMessage = '[$level] $time: $message';
      if (error != null) {
        developer.log(logMessage, error: error, stackTrace: stackTrace, name: 'HelperHiveApp');
      } else {
        debugPrint(logMessage);
      }
    }
  }
}
