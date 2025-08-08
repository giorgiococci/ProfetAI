import 'package:sqflite/sqflite.dart';
import '../../models/bio/user_bio.dart';
import '../../models/bio/biographical_insight.dart';
import '../../models/bio/generated_bio.dart';
import '../../utils/app_logger.dart';
import '../../utils/privacy/privacy_levels.dart';
import '../../utils/bio/insight_source_type.dart';
import '../database_service.dart';

/// Service for managing user biographical data storage and retrieval
/// 
/// This service handles CRUD operations for user bio data and insights,
/// ensuring privacy compliance and efficient data management
class BioStorageService {
  static const String _component = 'BioStorageService';
  static const String _defaultUserId = 'default_user'; // For single-user app
  
  final DatabaseService _databaseService = DatabaseService();
  
  // Singleton pattern
  static final BioStorageService _instance = BioStorageService._internal();
  factory BioStorageService() => _instance;
  BioStorageService._internal();

  /// Initialize or get the user bio record
  Future<UserBio> initializeUserBio({String? userId}) async {
    try {
      userId = userId ?? _defaultUserId;
      AppLogger.logInfo(_component, 'Initializing user bio for: $userId');
      
      final Database db = await _databaseService.database;
      
      // Check if user bio already exists
      final existingBioResult = await db.query(
        'user_bio',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (existingBioResult.isNotEmpty) {
        // Bio exists, load it with insights
        final bioMap = existingBioResult.first;
        final bio = UserBio.fromMap(bioMap);
        final bioWithInsights = await _loadInsightsForBio(bio);
        
        AppLogger.logInfo(_component, 'Existing user bio loaded with ${bioWithInsights.insights.length} insights');
        return bioWithInsights;
      } else {
        // Create new bio
        final now = DateTime.now();
        final newBio = UserBio(
          userId: userId,
          createdAt: now,
          updatedAt: now,
        );
        
        final bioId = await db.insert('user_bio', newBio.toMap());
        final bioWithId = newBio.copyWith(id: bioId);
        
        AppLogger.logInfo(_component, 'New user bio created with ID: $bioId');
        return bioWithId;
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize user bio', e);
      rethrow;
    }
  }

  /// Load insights for a bio record
  Future<UserBio> _loadInsightsForBio(UserBio bio) async {
    try {
      final db = await _databaseService.database;
      
      final insightsResult = await db.query(
        'biographical_insights',
        where: 'user_bio_id = ?',
        whereArgs: [bio.id],
        orderBy: 'extracted_at DESC',
      );
      
      final insights = insightsResult
          .map((map) => BiographicalInsight.fromMap(map))
          .toList();
      
      return bio.copyWith(insights: insights);
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load insights for bio', e);
      return bio; // Return bio without insights if loading fails
    }
  }

  /// Add a new biographical insight
  Future<BiographicalInsight> addInsight({
    required String content,
    required String category,
    required String sourceQuestionId,
    required String sourceAnswer,
    required String extractedFrom,
    required PrivacyLevel privacyLevel,
    required InsightSourceType sourceType,
    String? userId,
  }) async {
    try {
      userId = userId ?? _defaultUserId;
      AppLogger.logInfo(_component, 'Adding new insight for user: $userId');
      AppLogger.logInfo(_component, 'Insight content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
      AppLogger.logInfo(_component, 'Source type: ${sourceType.displayName}');
      
      // Get or create user bio
      final userBio = await initializeUserBio(userId: userId);
      if (userBio.id == null) {
        throw Exception('Failed to get user bio ID');
      }
      
      // Create insight
      final insight = BiographicalInsight(
        content: content,
        category: category,
        sourceQuestionId: sourceQuestionId,
        sourceAnswer: sourceAnswer,
        extractedFrom: extractedFrom,
        privacyLevel: privacyLevel,
        sourceType: sourceType,
        confidenceScore: 0.8, // Default confidence score
        extractedAt: DateTime.now(),
      );
      
      // Store insight
      final db = await _databaseService.database;
      final insightMap = insight.toMap();
      insightMap['user_bio_id'] = userBio.id;
      
      final insightId = await db.insert('biographical_insights', insightMap);
      final storedInsight = insight.copyWith(id: insightId);
      
      // Update bio timestamp
      await _updateBioTimestamp(userBio.id!);
      
      AppLogger.logInfo(_component, 'Insight stored successfully with ID: $insightId');
      return storedInsight;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to add biographical insight', e);
      rethrow;
    }
  }

  /// Get user bio with all insights
  Future<UserBio?> getUserBio({String? userId}) async {
    try {
      userId = userId ?? _defaultUserId;
      
      final db = await _databaseService.database;
      
      final bioResult = await db.query(
        'user_bio',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (bioResult.isEmpty) {
        AppLogger.logInfo(_component, 'No bio found for user: $userId');
        return null;
      }
      
      final bio = UserBio.fromMap(bioResult.first);
      final bioWithInsights = await _loadInsightsForBio(bio);
      
      AppLogger.logInfo(_component, 'User bio loaded with ${bioWithInsights.insights.length} insights');
      return bioWithInsights;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get user bio', e);
      return null;
    }
  }

  /// Get insights for context (only safe, active insights)
  Future<List<BiographicalInsight>> getContextInsights({String? userId, int limit = 10}) async {
    try {
      userId = userId ?? _defaultUserId;
      
      final userBio = await getUserBio(userId: userId);
      if (userBio == null) return [];
      
      final contextInsights = userBio.safeInsightsForContext;
      
      // Sort by usage frequency and recency
      contextInsights.sort((a, b) {
        // Prioritize recent insights that haven't been used much
        final aScore = (a.isRecent(days: 30) ? 10 : 0) - a.usageCount;
        final bScore = (b.isRecent(days: 30) ? 10 : 0) - b.usageCount;
        return bScore.compareTo(aScore);
      });
      
      final selectedInsights = contextInsights.take(limit).toList();
      
      // Update usage count for selected insights
      for (final insight in selectedInsights) {
        await _incrementInsightUsage(insight.id!);
      }
      
      AppLogger.logInfo(_component, 'Retrieved ${selectedInsights.length} context insights');
      return selectedInsights;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get context insights', e);
      return [];
    }
  }

  /// Generate context summary for prophet interactions
  Future<String> generateContextSummary({String? userId, int maxInsights = 8}) async {
    try {
      final insights = await getContextInsights(userId: userId, limit: maxInsights);
      
      if (insights.isEmpty) return '';
      
      final contextParts = insights.map((insight) => insight.content).toList();
      final summary = contextParts.join('. ');
      
      AppLogger.logInfo(_component, 'Generated context summary with ${insights.length} insights');
      return summary;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate context summary', e);
      return '';
    }
  }

  /// Update insight usage statistics
  Future<void> _incrementInsightUsage(int insightId) async {
    try {
      final db = await _databaseService.database;
      
      await db.rawUpdate('''
        UPDATE biographical_insights 
        SET usage_count = usage_count + 1, last_used_at = ?
        WHERE id = ?
      ''', [DateTime.now().millisecondsSinceEpoch, insightId]);
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to update insight usage: $e');
      // Non-critical error, don't rethrow
    }
  }

  /// Update bio timestamp
  Future<void> _updateBioTimestamp(int bioId) async {
    try {
      final db = await _databaseService.database;
      
      await db.update(
        'user_bio',
        {'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [bioId],
      );
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to update bio timestamp: $e');
      // Non-critical error, don't rethrow
    }
  }

  /// Delete a specific insight
  Future<bool> deleteInsight(int insightId) async {
    try {
      AppLogger.logInfo(_component, 'Deleting insight with ID: $insightId');
      
      final db = await _databaseService.database;
      final rowsAffected = await db.delete(
        'biographical_insights',
        where: 'id = ?',
        whereArgs: [insightId],
      );
      
      final success = rowsAffected > 0;
      AppLogger.logInfo(_component, 'Insight deletion success: $success');
      return success;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete insight', e);
      return false;
    }
  }

  /// Delete all insights for a user
  Future<bool> deleteAllInsights({String? userId}) async {
    try {
      userId = userId ?? _defaultUserId;
      AppLogger.logInfo(_component, 'Deleting all insights for user: $userId');
      
      final db = await _databaseService.database;
      
      // Get bio ID first
      final bioResult = await db.query(
        'user_bio',
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (bioResult.isEmpty) {
        AppLogger.logInfo(_component, 'No bio found for user, nothing to delete');
        return true;
      }
      
      final bioId = bioResult.first['id'] as int;
      
      // Delete all insights
      final rowsAffected = await db.delete(
        'biographical_insights',
        where: 'user_bio_id = ?',
        whereArgs: [bioId],
      );
      
      AppLogger.logInfo(_component, 'Deleted $rowsAffected insights');
      return true;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete all insights', e);
      return false;
    }
  }

  /// Delete all biographical data for a user (insights, generated bio, and user bio record)
  Future<bool> deleteAllBioData({String? userId}) async {
    try {
      userId = userId ?? _defaultUserId;
      AppLogger.logInfo(_component, 'Deleting all biographical data for user: $userId');
      
      final db = await _databaseService.database;
      
      // Start transaction for atomic deletion
      return await db.transaction<bool>((txn) async {
        // Get bio ID first
        final bioResult = await txn.query(
          'user_bio',
          columns: ['id'],
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        if (bioResult.isEmpty) {
          AppLogger.logInfo(_component, 'No bio data found for user, nothing to delete');
          return true;
        }
        
        final bioId = bioResult.first['id'] as int;
        
        // Delete insights
        final insightsDeleted = await txn.delete(
          'biographical_insights',
          where: 'user_bio_id = ?',
          whereArgs: [bioId],
        );
        
        // Delete generated bio
        final generatedBioDeleted = await txn.delete(
          'generated_bio',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        // Delete user bio record
        final userBioDeleted = await txn.delete(
          'user_bio',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        AppLogger.logInfo(_component, 'Deleted $insightsDeleted insights, $generatedBioDeleted generated bio records, and $userBioDeleted user bio records');
        return true;
      });
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete all biographical data', e);
      return false;
    }
  }

  /// Enable or disable bio collection for a user
  Future<bool> setBioEnabled({String? userId, required bool enabled}) async {
    try {
      userId = userId ?? _defaultUserId;
      AppLogger.logInfo(_component, 'Setting bio enabled to $enabled for user: $userId');
      
      final db = await _databaseService.database;
      
      final rowsAffected = await db.update(
        'user_bio',
        {'is_enabled': enabled ? 1 : 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      final success = rowsAffected > 0;
      AppLogger.logInfo(_component, 'Bio enabled update success: $success');
      return success;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update bio enabled status', e);
      return false;
    }
  }

  /// Get bio statistics
  Future<Map<String, dynamic>> getBioStatistics({String? userId}) async {
    try {
      userId = userId ?? _defaultUserId;
      
      final userBio = await getUserBio(userId: userId);
      if (userBio == null) {
        return {
          'hasData': false,
          'totalInsights': 0,
          'activeInsights': 0,
          'isEnabled': false,
        };
      }
      
      final stats = userBio.getStatistics();
      stats['hasData'] = true;
      
      return stats;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get bio statistics', e);
      return {
        'hasData': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if service is healthy
  Future<bool> isServiceHealthy() async {
    try {
      return await _databaseService.isDatabaseHealthy();
    } catch (e) {
      AppLogger.logError(_component, 'Bio service health check failed', e);
      return false;
    }
  }

  /// Get insights for a user
  Future<List<BiographicalInsight>> getInsights({String? userId}) async {
    try {
      userId = userId ?? _defaultUserId;
      final userBio = await getUserBio(userId: userId);
      return userBio?.insights ?? [];
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get insights for user: $userId', e);
      return [];
    }
  }

  /// Save generated bio
  Future<void> saveGeneratedBio({
    required String userId,
    required GeneratedBio generatedBio,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Saving generated bio for user: $userId');
      AppLogger.logInfo(_component, 'Bio has ${generatedBio.sections.length} sections');
      
      final Database db = await _databaseService.database;
      
      final bioWithId = generatedBio.copyWith(
        id: generatedBio.id.isEmpty ? _generateUuid() : generatedBio.id,
        userId: userId,
      );
      
      AppLogger.logInfo(_component, 'Generated bio ID: ${bioWithId.id}');
      
      final bioMap = bioWithId.toMap();
      AppLogger.logInfo(_component, 'Bio map keys: ${bioMap.keys.join(', ')}');
      
      await db.insert('generated_bio', bioMap, conflictAlgorithm: ConflictAlgorithm.replace);
      
      AppLogger.logInfo(_component, 'Generated bio saved successfully to database');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to save generated bio', e);
      rethrow;
    }
  }

  /// Get generated bio for a user
  Future<GeneratedBio?> getGeneratedBio({required String userId}) async {
    try {
      AppLogger.logInfo(_component, 'Getting generated bio for user: $userId');
      
      final Database db = await _databaseService.database;
      
      final results = await db.query(
        'generated_bio',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      AppLogger.logInfo(_component, 'Query returned ${results.length} results');
      
      if (results.isEmpty) {
        AppLogger.logInfo(_component, 'No generated bio found for user: $userId');
        return null;
      }
      
      final bioMap = results.first;
      AppLogger.logInfo(_component, 'Bio map keys: ${bioMap.keys.join(', ')}');
      
      final generatedBio = GeneratedBio.fromMap(bioMap);
      AppLogger.logInfo(_component, 'Generated bio loaded with ${generatedBio.sections.length} sections');
      
      return generatedBio;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get generated bio for user: $userId', e);
      return null;
    }
  }

  /// Update bio last used timestamp
  Future<void> updateBioLastUsed({required String userId}) async {
    try {
      final Database db = await _databaseService.database;
      
      await db.update(
        'generated_bio',
        {'last_used_at': DateTime.now().millisecondsSinceEpoch},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update bio last used for user: $userId', e);
      // Don't rethrow - this is not critical
    }
  }

  /// Generate UUID for IDs
  String _generateUuid() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'bio_${random}_${(random * 1000) % 1000000}';
  }
}
