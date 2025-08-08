/// Debug script to check insights source types and fix bio generation issue
import '../../services/bio/bio_storage_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_logger.dart';
import '../../utils/bio/insight_source_type.dart';

class BioDebugHelper {
  static const String _component = 'BioDebugHelper';
  
  /// Debug insights source types and classification
  static Future<void> debugInsightsSourceTypes() async {
    try {
      final bioStorage = BioStorageService();
      final userBio = await bioStorage.getUserBio(userId: 'default_user');
      
      if (userBio == null) {
        AppLogger.logInfo(_component, 'No user bio found');
        return;
      }
      
      AppLogger.logInfo(_component, 'Found ${userBio.insights.length} insights:');
      
      for (int i = 0; i < userBio.insights.length; i++) {
        final insight = userBio.insights[i];
        AppLogger.logInfo(_component, 'Insight $i:');
        AppLogger.logInfo(_component, '  Content: "${insight.content}"');
        AppLogger.logInfo(_component, '  Source Type: ${insight.sourceType.displayName} (${insight.sourceType.dbValue})');
        AppLogger.logInfo(_component, '  Privacy Level: ${insight.privacyLevel.displayName}');
        AppLogger.logInfo(_component, '  Can Use For Context: ${insight.privacyLevel.canUseForContext}');
        AppLogger.logInfo(_component, '  Should Use In Bio: ${insight.sourceType.shouldUseInBio}');
        AppLogger.logInfo(_component, '  Usable: ${insight.sourceType == InsightSourceType.user && insight.privacyLevel.canUseForContext}');
        AppLogger.logInfo(_component, '---');
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to debug insights', e);
    }
  }
  
  /// Fix existing insights to have USER source type if they're from test data
  static Future<void> fixExistingInsightsSourceType() async {
    try {
      AppLogger.logInfo(_component, 'Starting to fix existing insights source types');
      
      final databaseService = DatabaseService();
      final db = await databaseService.database;
      
      // Update all existing insights to be USER type if they're from test data
      final result = await db.rawUpdate('''
        UPDATE biographical_insights 
        SET source_type = ? 
        WHERE source_type IS NULL OR source_type = 1
      ''', [InsightSourceType.user.dbValue]);
      
      AppLogger.logInfo(_component, 'Updated $result insights to USER source type');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to fix insights source types', e);
    }
  }
}
