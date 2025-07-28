import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/app_logger.dart';

/// Database service for managing SQLite database operations
/// 
/// This service handles database initialization, schema creation,
/// and provides a foundation for all database operations
class DatabaseService {
  static const String _component = 'DatabaseService';
  static const String _databaseName = 'profet_ai.db';
  static const int _databaseVersion = 1;
  
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Get the database instance, initializing if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    AppLogger.logInfo(_component, 'Initializing database...');
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);
      
      AppLogger.logInfo(_component, 'Database path: $path');
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize database', e);
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.logInfo(_component, 'Creating database tables...');
    
    try {
      // Create visions table
      await db.execute('''
        CREATE TABLE visions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          question TEXT,
          answer TEXT NOT NULL,
          prophet_type TEXT NOT NULL,
          feedback_type TEXT,
          timestamp INTEGER NOT NULL,
          is_ai_generated INTEGER DEFAULT 0
        )
      ''');

      // Create indexes for efficient querying
      await db.execute('''
        CREATE INDEX idx_visions_timestamp ON visions(timestamp DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_visions_prophet_type ON visions(prophet_type)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_visions_feedback_type ON visions(feedback_type)
      ''');

      // Create full-text search virtual table for vision content
      await db.execute('''
        CREATE VIRTUAL TABLE visions_fts USING fts5(
          title, question, answer, 
          content='visions', 
          content_rowid='id'
        )
      ''');

      // Create triggers to keep FTS table in sync
      await db.execute('''
        CREATE TRIGGER visions_ai AFTER INSERT ON visions BEGIN
          INSERT INTO visions_fts(rowid, title, question, answer) 
          VALUES (new.id, new.title, new.question, new.answer);
        END
      ''');

      await db.execute('''
        CREATE TRIGGER visions_ad AFTER DELETE ON visions BEGIN
          INSERT INTO visions_fts(visions_fts, rowid, title, question, answer) 
          VALUES('delete', old.id, old.title, old.question, old.answer);
        END
      ''');

      await db.execute('''
        CREATE TRIGGER visions_au AFTER UPDATE ON visions BEGIN
          INSERT INTO visions_fts(visions_fts, rowid, title, question, answer) 
          VALUES('delete', old.id, old.title, old.question, old.answer);
          INSERT INTO visions_fts(rowid, title, question, answer) 
          VALUES (new.id, new.title, new.question, new.answer);
        END
      ''');

      AppLogger.logInfo(_component, 'Database tables created successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to create database tables', e);
      rethrow;
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.logInfo(_component, 'Upgrading database from v$oldVersion to v$newVersion');
    
    // Future schema migrations will be handled here
    // For now, we only have version 1
  }

  /// Handle database open
  Future<void> _onOpen(Database db) async {
    AppLogger.logInfo(_component, 'Database opened successfully');
    
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Configure journal mode for better performance
    await db.execute('PRAGMA journal_mode = WAL');
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      
      final visionCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM visions')
      ) ?? 0;
      
      final prophetsStats = await db.rawQuery('''
        SELECT prophet_type, COUNT(*) as count 
        FROM visions 
        GROUP BY prophet_type
      ''');
      
      final feedbackStats = await db.rawQuery('''
        SELECT feedback_type, COUNT(*) as count 
        FROM visions 
        WHERE feedback_type IS NOT NULL
        GROUP BY feedback_type
      ''');
      
      return {
        'totalVisions': visionCount,
        'prophetStats': prophetsStats,
        'feedbackStats': feedbackStats,
        'databaseVersion': _databaseVersion,
        'databasePath': await getDatabasesPath(),
      };
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get database stats', e);
      return {};
    }
  }

  /// Check if database is properly initialized
  Future<bool> isDatabaseHealthy() async {
    try {
      final db = await database;
      
      // Check if main table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='visions'"
      );
      
      if (tables.isEmpty) {
        AppLogger.logWarning(_component, 'Visions table not found');
        return false;
      }
      
      // Check if FTS table exists
      final ftsTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='visions_fts'"
      );
      
      if (ftsTables.isEmpty) {
        AppLogger.logWarning(_component, 'FTS table not found');
        return false;
      }
      
      AppLogger.logInfo(_component, 'Database health check passed');
      return true;
      
    } catch (e) {
      AppLogger.logError(_component, 'Database health check failed', e);
      return false;
    }
  }

  /// Delete all data (for user profile "delete all visions" feature)
  Future<void> deleteAllData() async {
    try {
      final db = await database;
      
      AppLogger.logInfo(_component, 'Deleting all vision data...');
      
      // Delete all visions (triggers will handle FTS cleanup)
      await db.delete('visions');
      
      // Vacuum to reclaim space
      await db.execute('VACUUM');
      
      AppLogger.logInfo(_component, 'All vision data deleted successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete all data', e);
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      AppLogger.logInfo(_component, 'Closing database connection');
      await _database!.close();
      _database = null;
    }
  }

  /// Reset database (delete and recreate)
  Future<void> resetDatabase() async {
    try {
      AppLogger.logInfo(_component, 'Resetting database...');
      
      // Close existing connection
      await close();
      
      // Delete database file
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);
      final file = File(path);
      
      if (await file.exists()) {
        await file.delete();
        AppLogger.logInfo(_component, 'Database file deleted');
      }
      
      // Reinitialize
      _database = await _initDatabase();
      
      AppLogger.logInfo(_component, 'Database reset completed');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to reset database', e);
      rethrow;
    }
  }
}
