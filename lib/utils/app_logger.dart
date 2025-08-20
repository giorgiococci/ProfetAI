/// Centralized logging system for Orakl
/// 
/// This handles all logging throughout the app with configurable debug levels
/// Debug logging is controlled by build-time flags and can be disabled in production

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static const bool _isDebugMode = bool.fromEnvironment(
    'DEBUG_LOGGING',
    defaultValue: false,
  );
  
  static const String _appName = 'Orakl';
  static final List<LogEntry> _logs = [];
  static const int _maxLogEntries = 500; // Increased from 100 to 500
  
  // Desktop-specific logging
  static bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  static String? _logFilePath;

  /// Log levels
  static const String info = 'INFO';
  static const String warning = 'WARN';
  static const String error = 'ERROR';
  static const String debug = 'DEBUG';

  /// Log an informational message
  static void logInfo(String component, String message) {
    _log(info, component, message);
  }

  /// Log a warning message
  static void logWarning(String component, String message) {
    _log(warning, component, message);
  }

  /// Log an error message
  static void logError(String component, String message, [Object? error]) {
    final fullMessage = error != null ? '$message: $error' : message;
    _log(AppLogger.error, component, fullMessage);
  }

  /// Log a debug message (only in debug mode)
  static void logDebug(String component, String message) {
    if (_isDebugMode) {
      _log(debug, component, message);
    }
  }

  /// Internal logging method
  static void _log(String level, String component, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = LogEntry(
      timestamp: timestamp,
      level: level,
      component: component,
      message: message,
    );
    
    // Add to internal log
    _logs.add(logEntry);
    
    // Keep only the last N entries
    if (_logs.length > _maxLogEntries) {
      _logs.removeAt(0);
    }
    
    // Enhanced console output logic:
    // - Always print errors and warnings
    // - In debug mode: print all logs to help with development (even on mobile)
    // - In release mode: only print errors/warnings
    final shouldPrintToConsole = level == error || level == warning || 
        _isDebugMode || kDebugMode;
        
    if (shouldPrintToConsole) {
      final logMessage = '[$_appName] [$timestamp] [$level] [$component] $message';
      print(logMessage);
      
      // Also write to file on desktop platforms (only when actually running on desktop)
      if (_isDesktop) {
        _writeToFile(logMessage);
      }
    }
  }
  
  /// Write log entry to file (desktop only)
  static void _writeToFile(String logMessage) {
    try {
      if (_logFilePath == null) {
        _initializeLogFile();
      }
      
      if (_logFilePath != null) {
        final file = File(_logFilePath!);
        file.writeAsStringSync('$logMessage\n', mode: FileMode.append);
      }
    } catch (e) {
      // Silently fail if file logging doesn't work
      // Don't use AppLogger here to avoid infinite recursion
      print('Failed to write to log file: $e');
    }
  }
  
  /// Initialize log file path (desktop only)
  static void _initializeLogFile() async {
    try {
      if (_isDesktop) {
        final directory = await getApplicationDocumentsDirectory();
        final logsDir = Directory('${directory.path}/Orakl/logs');
        
        if (!await logsDir.exists()) {
          await logsDir.create(recursive: true);
        }
        
        final now = DateTime.now();
        final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        _logFilePath = '${logsDir.path}/orakl_$dateStr.log';
        
        // Write session start marker
        final file = File(_logFilePath!);
        await file.writeAsString('\n=== Orakl Session Started: ${DateTime.now().toIso8601String()} ===\n', mode: FileMode.append);
      }
    } catch (e) {
      // Silently fail if file initialization doesn't work
      print('Failed to initialize log file: $e');
    }
  }

  /// Get all logs
  static List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Get logs for a specific component
  static List<LogEntry> getLogsForComponent(String component) {
    return _logs.where((log) => log.component == component).toList();
  }

  /// Get logs formatted as string
  static String getLogsAsString({String? component, int? lastN}) {
    var filteredLogs = component != null 
        ? getLogsForComponent(component) 
        : _logs;
    
    if (lastN != null && lastN > 0) {
      filteredLogs = filteredLogs.length > lastN 
          ? filteredLogs.sublist(filteredLogs.length - lastN)
          : filteredLogs;
    }
    
    return filteredLogs.map((log) => log.toString()).join('\n');
  }

  /// Clear all logs
  static void clear() {
    _logs.clear();
  }

  /// Check if debug mode is enabled
  static bool get isDebugMode => _isDebugMode;
}

/// Log entry data class
class LogEntry {
  final String timestamp;
  final String level;
  final String component;
  final String message;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.component,
    required this.message,
  });

  @override
  String toString() {
    return '[$timestamp] [$level] [$component] $message';
  }
}
