/// Database migration to add source_type column to biographical_insights table
/// 
/// This migration adds the ability to distinguish between insights derived 
/// from user statements vs prophet responses
class BiographicalInsightSourceTypeMigration {
  /// Migration version identifier
  static const int migrationVersion = 5;
  
  /// SQL to add source_type column with default value of 0 (USER type)
  static const String addSourceTypeColumnSql = '''
    ALTER TABLE biographical_insights 
    ADD COLUMN source_type INTEGER NOT NULL DEFAULT 0;
  ''';
  
  /// SQL to create index on source_type for performance
  static const String addSourceTypeIndexSql = '''
    CREATE INDEX idx_biographical_insights_source_type 
    ON biographical_insights(source_type);
  ''';
  
  /// SQL to update existing records to have proper source type
  /// This analyzes existing insights to classify them appropriately
  static const String updateExistingRecordsSql = '''
    -- Set source_type to PROPHET (1) for insights that contain prophet-specific language
    UPDATE biographical_insights 
    SET source_type = 1 
    WHERE 
      content LIKE '%prophet%' OR 
      content LIKE '%guidance%' OR 
      content LIKE '%wisdom%' OR
      content LIKE '%teaching%' OR
      source_answer IS NOT NULL AND source_answer != '';
    
    -- Keep source_type as USER (0) for all others (default behavior)
  ''';
  
  /// Complete migration SQL combining all operations
  static List<String> get migrationSql => [
    addSourceTypeColumnSql,
    addSourceTypeIndexSql,
    updateExistingRecordsSql,
  ];
  
  /// Rollback SQL to remove the source_type column
  static List<String> get rollbackSql => [
    'DROP INDEX IF EXISTS idx_biographical_insights_source_type;',
    'ALTER TABLE biographical_insights DROP COLUMN source_type;',
  ];
}
