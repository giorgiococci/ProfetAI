import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../utils/app_logger.dart';

/// Database service for managing SQLite database operations
/// 
/// This service handles database initialization, schema creation,
/// and provides a foundation for all database operations
class DatabaseService {
  static const String _component = 'DatabaseService';
  static const String _databaseName = 'profet_ai.db';
  static const int _databaseVersion = 4;
  
  static Database? _database;
  static bool? _fts5Available;
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Check if FTS5 is available in the current SQLite installation
  bool get isFts5Available => _fts5Available ?? false;

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
      // Try multiple initialization strategies
      return await _tryInitializeDatabase();
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize database', e);
      rethrow;
    }
  }

  /// Try different database initialization strategies
  Future<Database> _tryInitializeDatabase() async {
    AppLogger.logInfo(_component, 'Detecting platform for database initialization...');
    
    // Initialize the appropriate database factory based on platform
    if (kIsWeb) {
      // Web platform
      AppLogger.logInfo(_component, 'Detected web platform, using sqflite_ffi_web');
      try {
        databaseFactory = databaseFactoryFfiWeb;
        AppLogger.logInfo(_component, 'sqflite_ffi_web factory set successfully');
      } catch (e) {
        AppLogger.logError(_component, 'Failed to set sqflite_ffi_web factory', e);
        throw Exception('Web database initialization failed: $e');
      }
    } else {
      // Check if we're on desktop or mobile
      try {
        final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
        if (isDesktop) {
          // Desktop platform
          AppLogger.logInfo(_component, 'Detected desktop platform, using sqflite_ffi');
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
        } else {
          // Mobile platform (Android/iOS) - use default sqflite
          AppLogger.logInfo(_component, 'Detected mobile platform, using default sqflite');
          // databaseFactory is already set to default for mobile
        }
      } catch (e) {
        // Fallback: if platform detection fails, try sqflite_ffi
        AppLogger.logWarning(_component, 'Platform detection failed, trying sqflite_ffi: $e');
        try {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          AppLogger.logInfo(_component, 'Using sqflite_ffi as fallback');
        } catch (e2) {
          AppLogger.logWarning(_component, 'sqflite_ffi failed, using default sqflite: $e2');
        }
      }
    }
    
    return await _openDatabase();
  }

  /// Open the database with current configuration
  Future<Database> _openDatabase() async {
    try {
      String path;
      
      if (kIsWeb) {
        // For web, use a simple database name without path manipulation
        path = _databaseName;
        AppLogger.logInfo(_component, 'Web database path: $path');
      } else {
        // For mobile/desktop, use the documents directory
        final documentsDirectory = await getDatabasesPath();
        path = join(documentsDirectory, _databaseName);
        AppLogger.logInfo(_component, 'Native database path: $path');
      }
      
      AppLogger.logInfo(_component, 'Opening database...');
      final database = await _openDatabaseWithRecovery(path);
      
      AppLogger.logInfo(_component, 'Database opened successfully');
      return database;
    } catch (e) {
      AppLogger.logError(_component, 'Failed to open database', e);
      rethrow;
    }
  }

  /// Open database with corruption recovery capability
  Future<Database> _openDatabaseWithRecovery(String path) async {
    try {
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      AppLogger.logWarning(_component, 'Database opening failed, attempting recovery: $e');
      
      // If opening fails, try to delete and recreate the database
      try {
        if (!kIsWeb && await File(path).exists()) {
          AppLogger.logInfo(_component, 'Deleting corrupted database file');
          await File(path).delete();
        }
        
        // Try opening again (will trigger onCreate)
        return await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onOpen: _onOpen,
        );
      } catch (e2) {
        AppLogger.logError(_component, 'Database recovery failed', e2);
        rethrow;
      }
    }
  }

  /// Detect if FTS5 is available in the current SQLite installation
  Future<void> _detectFts5Support(Database db) async {
    try {
      // Try to create a temporary FTS5 table to test support
      await db.execute('CREATE VIRTUAL TABLE fts5_test USING fts5(content)');
      await db.execute('DROP TABLE fts5_test');
      
      _fts5Available = true;
      AppLogger.logInfo(_component, 'FTS5 support detected and available');
    } catch (e) {
      _fts5Available = false;
      AppLogger.logWarning(_component, 'FTS5 not available, using fallback search: $e');
    }
    
    // Also detect other mobile database capabilities for future use
    await _detectAdditionalCapabilities(db);
  }

  /// Detect additional database capabilities for mobile compatibility
  Future<void> _detectAdditionalCapabilities(Database db) async {
    try {
      // Test CASE WHEN support
      await db.rawQuery('SELECT CASE WHEN 1=1 THEN 1 ELSE 0 END as test');
      AppLogger.logInfo(_component, 'CASE WHEN statements supported');
    } catch (e) {
      AppLogger.logWarning(_component, 'CASE WHEN statements not fully supported: $e');
    }
    
    try {
      // Test TRIGGER support by creating a temporary trigger
      await db.execute('''
        CREATE TEMP TABLE test_table (id INTEGER, value TEXT)
      ''');
      await db.execute('''
        CREATE TEMP TRIGGER test_trigger AFTER INSERT ON test_table BEGIN
          UPDATE test_table SET value = 'triggered' WHERE id = NEW.id;
        END
      ''');
      await db.execute('DROP TRIGGER test_trigger');
      await db.execute('DROP TABLE test_table');
      AppLogger.logInfo(_component, 'TRIGGER support confirmed');
    } catch (e) {
      AppLogger.logWarning(_component, 'TRIGGER support limited or unavailable: $e');
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.logInfo(_component, 'Creating database tables...');
    
    try {
      // Detect FTS5 availability
      await _detectFts5Support(db);
      
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

      // Create bio-related tables
      await _createBioTables(db);

      // Create generated bio table
      await _createGeneratedBioTable(db);

      // Create full-text search virtual table only if FTS5 is available
      await _createFtsTableIfSupported(db);

      AppLogger.logInfo(_component, 'Database tables created successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to create database tables', e);
      rethrow;
    }
  }

  /// Create FTS5 table and triggers if FTS5 is supported
  Future<void> _createFtsTableIfSupported(Database db) async {
    if (!isFts5Available) {
      AppLogger.logInfo(_component, 'Skipping FTS5 table creation - not supported');
      return;
    }

    try {
      // Create full-text search virtual table for vision content
      await db.execute('''
        CREATE VIRTUAL TABLE visions_fts USING fts5(
          title, question, answer, 
          content='visions', 
          content_rowid='id'
        )
      ''');

      // Create triggers to keep FTS table in sync (with mobile compatibility check)
      await _createFtsTriggersIfSupported(db);

      AppLogger.logInfo(_component, 'FTS5 tables created successfully');
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to create FTS5 tables, disabling FTS5: $e');
      _fts5Available = false;
    }
  }

  /// Create FTS triggers with mobile compatibility check
  Future<void> _createFtsTriggersIfSupported(Database db) async {
    try {
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

      AppLogger.logInfo(_component, 'FTS5 triggers created successfully');
    } catch (e) {
      AppLogger.logWarning(_component, 'FTS5 triggers not supported on this platform, FTS sync disabled: $e');
      // FTS5 table will still work, just won't auto-sync with changes
    }
  }

  /// Create biographical data tables
  Future<void> _createBioTables(Database db) async {
    AppLogger.logInfo(_component, 'Creating biographical data tables...');
    
    try {
      // Create user_bio table (main bio record per user)
      await db.execute('''
        CREATE TABLE user_bio (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL UNIQUE,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          is_enabled INTEGER DEFAULT 1
        )
      ''');

      // Create biographical_insights table (individual insights)
      await db.execute('''
        CREATE TABLE biographical_insights (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_bio_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          category TEXT NOT NULL DEFAULT 'general',
          source_question_id TEXT NOT NULL,
          source_answer TEXT NOT NULL,
          extracted_from TEXT NOT NULL,
          privacy_level TEXT NOT NULL,
          confidence_score REAL NOT NULL DEFAULT 0.0,
          extracted_at INTEGER NOT NULL,
          last_used_at INTEGER,
          usage_count INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (user_bio_id) REFERENCES user_bio (id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for efficient bio querying
      await db.execute('''
        CREATE INDEX idx_user_bio_user_id ON user_bio(user_id)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_biographical_insights_user_bio_id ON biographical_insights(user_bio_id)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_biographical_insights_privacy_level ON biographical_insights(privacy_level)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_biographical_insights_active ON biographical_insights(is_active)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_biographical_insights_extracted_at ON biographical_insights(extracted_at DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_biographical_insights_category ON biographical_insights(category)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_biographical_insights_confidence ON biographical_insights(confidence_score DESC)
      ''');

      AppLogger.logInfo(_component, 'Biographical data tables created successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to create biographical data tables', e);
      rethrow;
    }
  }

  /// Create generated_bio table for AI-generated biographical narratives
  Future<void> _createGeneratedBioTable(Database db) async {
    AppLogger.logInfo(_component, 'Creating generated_bio table...');
    
    try {
      // Create generated_bio table (AI-generated biographical narratives)
      await db.execute('''
        CREATE TABLE generated_bio (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL UNIQUE,
          sections_json TEXT NOT NULL,
          total_insights_used INTEGER NOT NULL,
          confidence_score REAL NOT NULL,
          generated_at INTEGER NOT NULL,
          last_used_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES user_bio (user_id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for generated_bio table
      await db.execute('''
        CREATE INDEX idx_generated_bio_user_id ON generated_bio(user_id)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_generated_bio_generated_at ON generated_bio(generated_at DESC)
      ''');

      AppLogger.logInfo(_component, 'Generated bio table created successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to create generated bio table', e);
      rethrow;
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.logInfo(_component, 'Upgrading database from v$oldVersion to v$newVersion');
    
    try {
      // Migration from version 1 to 2: Add biographical data tables
      if (oldVersion < 2) {
        AppLogger.logInfo(_component, 'Migrating to v2: Adding biographical data tables');
        await _createBioTables(db);
      }
      
      // Migration from version 2 to 3: Add generated_bio table
      if (oldVersion < 3) {
        AppLogger.logInfo(_component, 'Migrating to v3: Adding generated_bio table');
        await _createGeneratedBioTable(db);
      }
      
      // Migration from version 3 to 4: Fix biographical_insights schema
      if (oldVersion < 4) {
        AppLogger.logInfo(_component, 'Migrating to v4: Fixing biographical_insights schema');
        
        // Drop and recreate biographical_insights table with proper schema
        await db.execute('DROP TABLE IF EXISTS biographical_insights');
        
        // Recreate with proper schema
        await db.execute('''
          CREATE TABLE biographical_insights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_bio_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            category TEXT NOT NULL DEFAULT 'general',
            source_question_id TEXT NOT NULL,
            source_answer TEXT NOT NULL,
            extracted_from TEXT NOT NULL,
            privacy_level TEXT NOT NULL,
            confidence_score REAL NOT NULL DEFAULT 0.0,
            extracted_at INTEGER NOT NULL,
            last_used_at INTEGER,
            usage_count INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            FOREIGN KEY (user_bio_id) REFERENCES user_bio (id) ON DELETE CASCADE
          )
        ''');
        
        // Recreate indexes
        await db.execute('CREATE INDEX idx_biographical_insights_user_bio_id ON biographical_insights(user_bio_id)');
        await db.execute('CREATE INDEX idx_biographical_insights_privacy_level ON biographical_insights(privacy_level)');
        await db.execute('CREATE INDEX idx_biographical_insights_active ON biographical_insights(is_active)');
        await db.execute('CREATE INDEX idx_biographical_insights_extracted_at ON biographical_insights(extracted_at DESC)');
        await db.execute('CREATE INDEX idx_biographical_insights_category ON biographical_insights(category)');
        await db.execute('CREATE INDEX idx_biographical_insights_confidence ON biographical_insights(confidence_score DESC)');
        
        AppLogger.logInfo(_component, 'Biographical insights table recreated successfully');
      }
      
      // Future schema migrations will be handled here
      AppLogger.logInfo(_component, 'Database upgrade completed successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Database upgrade failed', e);
      rethrow;
    }
  }

  /// Handle database open
  Future<void> _onOpen(Database db) async {
    AppLogger.logInfo(_component, 'Database opened successfully');
    
    // Safely enable foreign key constraints (supported on most platforms)
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      AppLogger.logInfo(_component, 'Foreign keys enabled successfully');
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to enable foreign keys (not critical): $e');
    }
    
    // Configure journal mode based on platform
    await _configureDatabaseMode(db);
  }

  /// Configure database mode based on platform capabilities
  Future<void> _configureDatabaseMode(Database db) async {
    if (kIsWeb) {
      // Web platform - skip journal mode configuration
      AppLogger.logInfo(_component, 'Web platform detected, skipping journal mode configuration');
      return;
    }
    
    // For mobile platforms, try WAL mode but fallback gracefully
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Mobile platforms may have limited PRAGMA support
        AppLogger.logInfo(_component, 'Mobile platform detected, using conservative database settings');
        
        try {
          await db.execute('PRAGMA journal_mode = DELETE');
          AppLogger.logInfo(_component, 'DELETE journal mode enabled for mobile compatibility');
        } catch (e) {
          AppLogger.logWarning(_component, 'Failed to set journal mode on mobile: $e');
        }
      } else {
        // Desktop platforms - try WAL mode
        try {
          await db.execute('PRAGMA journal_mode = WAL');
          AppLogger.logInfo(_component, 'WAL journal mode enabled for desktop platform');
        } catch (e) {
          AppLogger.logWarning(_component, 'Failed to set WAL mode, trying DELETE mode: $e');
          try {
            await db.execute('PRAGMA journal_mode = DELETE');
            AppLogger.logInfo(_component, 'DELETE journal mode enabled as fallback');
          } catch (e2) {
            AppLogger.logWarning(_component, 'Failed to set any journal mode: $e2');
          }
        }
      }
    } catch (e) {
      AppLogger.logWarning(_component, 'Platform detection failed, skipping journal mode: $e');
    }
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
