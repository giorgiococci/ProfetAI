import '../models/vision.dart';
import '../models/vision_feedback.dart';
import '../utils/app_logger.dart';
import 'database_service.dart';

/// Service for managing vision storage operations
/// 
/// This service provides CRUD operations for visions, filtering,
/// searching, and pagination capabilities
class VisionStorageService {
  static const String _component = 'VisionStorageService';
  static const int defaultPageSize = 20;
  
  final DatabaseService _databaseService = DatabaseService();
  
  // Singleton pattern
  static final VisionStorageService _instance = VisionStorageService._internal();
  factory VisionStorageService() => _instance;
  VisionStorageService._internal();

  /// Store a new vision in the database
  Future<Vision> storeVision({
    required String title,
    String? question,
    required String answer,
    required String prophetType,
    FeedbackType? feedbackType,
    bool isAIGenerated = false,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Storing new vision with title: $title');
      
      final vision = Vision(
        title: title,
        question: question,
        answer: answer,
        prophetType: prophetType,
        feedbackType: feedbackType,
        timestamp: DateTime.now(),
        isAIGenerated: isAIGenerated,
      );
      
      final db = await _databaseService.database;
      final id = await db.insert('visions', vision.toMap());
      
      final storedVision = vision.copyWith(id: id);
      
      AppLogger.logInfo(_component, 'Vision stored successfully with ID: $id');
      return storedVision;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to store vision', e);
      rethrow;
    }
  }

  /// Get visions with filtering and pagination
  Future<List<Vision>> getVisions({
    VisionFilter? filter,
    int offset = 0,
    int limit = defaultPageSize,
    String orderBy = 'timestamp DESC',
  }) async {
    try {
      AppLogger.logInfo(_component, 'Getting visions with offset: $offset, limit: $limit');
      
      final db = await _databaseService.database;
      
      // Build query with filters
      final queryBuilder = _buildQuery(filter);
      final query = '''
        SELECT * FROM visions 
        ${queryBuilder['where']} 
        ORDER BY $orderBy 
        LIMIT $limit OFFSET $offset
      ''';
      
      final result = await db.rawQuery(query, queryBuilder['args']);
      final visions = result.map((map) => Vision.fromMap(map)).toList();
      
      AppLogger.logInfo(_component, 'Retrieved ${visions.length} visions');
      return visions;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get visions', e);
      return [];
    }
  }

  /// Get a single vision by ID
  Future<Vision?> getVisionById(int id) async {
    try {
      AppLogger.logInfo(_component, 'Getting vision by ID: $id');
      
      final db = await _databaseService.database;
      final result = await db.query(
        'visions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) {
        AppLogger.logWarning(_component, 'Vision not found with ID: $id');
        return null;
      }
      
      return Vision.fromMap(result.first);
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get vision by ID', e);
      return null;
    }
  }

  /// Search visions using full-text search
  Future<List<Vision>> searchVisions({
    required String searchQuery,
    VisionFilter? additionalFilters,
    int offset = 0,
    int limit = defaultPageSize,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Searching visions with query: $searchQuery');
      
      if (searchQuery.trim().isEmpty) {
        return getVisions(
          filter: additionalFilters,
          offset: offset,
          limit: limit,
        );
      }
      
      final db = await _databaseService.database;
      
      // Use FTS for text search combined with additional filters
      String baseQuery = '''
        SELECT v.* FROM visions v
        JOIN visions_fts fts ON v.id = fts.rowid
        WHERE visions_fts MATCH ?
      ''';
      
      List<dynamic> args = [searchQuery];
      
      // Add additional filters if provided
      if (additionalFilters != null) {
        final filterBuilder = _buildAdditionalFilters(additionalFilters);
        if (filterBuilder['where'].isNotEmpty) {
          baseQuery += ' AND ${filterBuilder['where']}';
          args.addAll(filterBuilder['args']);
        }
      }
      
      baseQuery += ' ORDER BY timestamp DESC LIMIT $limit OFFSET $offset';
      
      final result = await db.rawQuery(baseQuery, args);
      final visions = result.map((map) => Vision.fromMap(map)).toList();
      
      AppLogger.logInfo(_component, 'Found ${visions.length} visions matching search');
      return visions;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to search visions', e);
      return [];
    }
  }

  /// Update vision feedback
  Future<bool> updateVisionFeedback(int visionId, FeedbackType feedbackType) async {
    try {
      AppLogger.logInfo(_component, 'Updating feedback for vision ID: $visionId');
      
      final db = await _databaseService.database;
      final rowsAffected = await db.update(
        'visions',
        {'feedback_type': feedbackType.name},
        where: 'id = ?',
        whereArgs: [visionId],
      );
      
      final success = rowsAffected > 0;
      AppLogger.logInfo(_component, 'Feedback update success: $success');
      return success;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update vision feedback', e);
      return false;
    }
  }

  /// Delete a vision by ID
  Future<bool> deleteVision(int visionId) async {
    try {
      AppLogger.logInfo(_component, 'Deleting vision with ID: $visionId');
      
      final db = await _databaseService.database;
      final rowsAffected = await db.delete(
        'visions',
        where: 'id = ?',
        whereArgs: [visionId],
      );
      
      final success = rowsAffected > 0;
      AppLogger.logInfo(_component, 'Vision deletion success: $success');
      return success;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete vision', e);
      return false;
    }
  }

  /// Delete all visions (for user profile bulk delete)
  Future<bool> deleteAllVisions() async {
    try {
      AppLogger.logInfo(_component, 'Deleting all visions');
      
      await _databaseService.deleteAllData();
      
      AppLogger.logInfo(_component, 'All visions deleted successfully');
      return true;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete all visions', e);
      return false;
    }
  }

  /// Get total count of visions (with optional filter)
  Future<int> getVisionCount({VisionFilter? filter}) async {
    try {
      final db = await _databaseService.database;
      
      final queryBuilder = _buildQuery(filter);
      final query = '''
        SELECT COUNT(*) as count FROM visions 
        ${queryBuilder['where']}
      ''';
      
      final result = await db.rawQuery(query, queryBuilder['args']);
      return result.first['count'] as int;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get vision count', e);
      return 0;
    }
  }

  /// Get statistics about stored visions
  Future<Map<String, dynamic>> getVisionStatistics() async {
    try {
      AppLogger.logInfo(_component, 'Getting vision statistics');
      
      final db = await _databaseService.database;
      
      // Total count
      final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM visions');
      final total = totalResult.first['total'] as int;
      
      // Count by prophet
      final prophetStats = await db.rawQuery('''
        SELECT prophet_type, COUNT(*) as count 
        FROM visions 
        GROUP BY prophet_type
        ORDER BY count DESC
      ''');
      
      // Count by feedback type
      final feedbackStats = await db.rawQuery('''
        SELECT feedback_type, COUNT(*) as count 
        FROM visions 
        WHERE feedback_type IS NOT NULL
        GROUP BY feedback_type
        ORDER BY count DESC
      ''');
      
      // Count with/without questions
      final questionStats = await db.rawQuery('''
        SELECT 
          SUM(CASE WHEN question IS NOT NULL AND question != '' THEN 1 ELSE 0 END) as with_question,
          SUM(CASE WHEN question IS NULL OR question = '' THEN 1 ELSE 0 END) as without_question
        FROM visions
      ''');
      
      // Most recent visions
      final recentVisions = await db.rawQuery('''
        SELECT * FROM visions 
        ORDER BY timestamp DESC 
        LIMIT 5
      ''');
      
      return {
        'total': total,
        'prophetStats': prophetStats,
        'feedbackStats': feedbackStats,
        'questionStats': questionStats.first,
        'recentVisions': recentVisions.map((map) => Vision.fromMap(map)).toList(),
      };
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get vision statistics', e);
      return {};
    }
  }

  /// Build WHERE clause and arguments for vision queries
  Map<String, dynamic> _buildQuery(VisionFilter? filter) {
    if (filter == null || !filter.hasActiveFilters) {
      return {'where': '', 'args': <dynamic>[]};
    }
    
    List<String> conditions = [];
    List<dynamic> args = [];
    
    if (filter.prophetType != null) {
      conditions.add('prophet_type = ?');
      args.add(filter.prophetType);
    }
    
    if (filter.feedbackType != null) {
      conditions.add('feedback_type = ?');
      args.add(filter.feedbackType!.name);
    }
    
    if (filter.startDate != null) {
      conditions.add('timestamp >= ?');
      args.add(filter.startDate!.millisecondsSinceEpoch);
    }
    
    if (filter.endDate != null) {
      conditions.add('timestamp <= ?');
      args.add(filter.endDate!.millisecondsSinceEpoch);
    }
    
    if (filter.hasQuestion != null) {
      if (filter.hasQuestion!) {
        conditions.add('question IS NOT NULL AND question != ""');
      } else {
        conditions.add('(question IS NULL OR question = "")');
      }
    }
    
    final whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    
    return {'where': whereClause, 'args': args};
  }

  /// Build additional filter conditions for search queries
  Map<String, dynamic> _buildAdditionalFilters(VisionFilter filter) {
    List<String> conditions = [];
    List<dynamic> args = [];
    
    if (filter.prophetType != null) {
      conditions.add('v.prophet_type = ?');
      args.add(filter.prophetType);
    }
    
    if (filter.feedbackType != null) {
      conditions.add('v.feedback_type = ?');
      args.add(filter.feedbackType!.name);
    }
    
    if (filter.startDate != null) {
      conditions.add('v.timestamp >= ?');
      args.add(filter.startDate!.millisecondsSinceEpoch);
    }
    
    if (filter.endDate != null) {
      conditions.add('v.timestamp <= ?');
      args.add(filter.endDate!.millisecondsSinceEpoch);
    }
    
    if (filter.hasQuestion != null) {
      if (filter.hasQuestion!) {
        conditions.add('v.question IS NOT NULL AND v.question != ""');
      } else {
        conditions.add('(v.question IS NULL OR v.question = "")');
      }
    }
    
    final whereClause = conditions.join(' AND ');
    
    return {'where': whereClause, 'args': args};
  }

  /// Check if service is properly initialized
  Future<bool> isServiceHealthy() async {
    try {
      return await _databaseService.isDatabaseHealthy();
    } catch (e) {
      AppLogger.logError(_component, 'Service health check failed', e);
      return false;
    }
  }

  /// Close database connections (for cleanup)
  Future<void> close() async {
    await _databaseService.close();
  }
}
