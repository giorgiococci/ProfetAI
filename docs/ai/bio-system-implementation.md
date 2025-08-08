# Bio System Implementation - Phase 1 Complete

**Date:** August 8, 2025  
**Status:** Phase 1 Complete, Ready for Phase 2  
**Branch:** fix/reload_onboarding

## Overview

This document details the implementation of the AI-powered biographical information collection system for ProfetAI. The system analyzes user interactions with prophets to build personalized user profiles while maintaining strict privacy controls.

## System Architecture

### Core Concept

The bio system follows this workflow:
1. **Trigger** - After each prophet interaction, analyze the Q&A pair
2. **Process** - Extract relevant biographical insights using AI classification
3. **Filter** - Apply privacy-first filtering to protect sensitive information
4. **Store** - Save approved insights with confidence tracking
5. **Personalize** - Use collected bio data to customize future prophet responses

### Privacy-First Design

The system implements a 4-tier privacy classification with AI-powered content analysis to filter sensitive information before storage.

## Phase 1 Implementation Details

### 1. Privacy Framework - `lib/utils/privacy/`

**File:** `privacy_levels.dart`

**Purpose:** Core privacy classification system with 4-tier hierarchy

```dart
enum PrivacyLevel {
  public,     // General interests, hobbies, public opinions
  personal,   // Preferences, personality traits, life goals  
  sensitive,  // Financial status, health issues, family problems
  confidential // Medical conditions, financial details, locations, phone numbers
}
```

**Key Features:**
- `canStore` - Only public/personal data is stored
- `canUseForContext` - Only public/personal data used for prophet responses
- Extension methods for validation and display

**Critical Implementation Note:** The system defaults to NOT storing sensitive/confidential data. This is the foundation of privacy protection.

### 2. AI Privacy Filter - `lib/services/bio/privacy_filter_service.dart`

**Architecture:**
- **Primary** - Azure OpenAI analysis with structured prompts
- **Fallback** - Regex-based detection for offline scenarios
- **Integration** - Uses existing AIServiceManager infrastructure

**AI Analysis Prompt:**

```text
Analyze the following text for privacy sensitivity level:

TEXT: [user_content]

Classification Rules:
- PUBLIC: General interests, hobbies, opinions, preferences
- PERSONAL: Personality traits, goals, non-sensitive personal details
- SENSITIVE: Health mentions, financial references, family issues
- CONFIDENTIAL: Medical conditions, financial details, phone numbers, precise locations

Respond with only: PUBLIC, PERSONAL, SENSITIVE, or CONFIDENTIAL
```

**Fallback Regex Patterns:**
- **Phone Numbers:** `r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'`
- **Financial:** Keywords like "bank", "credit card", "salary", "debt"
- **Medical:** Keywords like "doctor", "medication", "diagnosis", "hospital"
- **Precise Locations:** Address patterns and specific location indicators

**Critical Implementation Note:** The AI analysis is the primary filter, but regex provides essential offline protection.

### 3. Data Models - `lib/models/bio/`

**File:** `biographical_insight.dart`

**Purpose:** Individual learned facts about users with privacy and usage tracking

```dart
class BiographicalInsight {
  String id;              // UUID identifier
  String userId;          // User identification
  String category;        // Insight categorization
  String content;         // The actual insight
  PrivacyLevel privacyLevel; // Privacy classification
  double confidenceScore; // AI confidence (0.0-1.0)
  String? sourceContext; // Original Q&A context
  int usageCount;        // How often used
  DateTime? lastUsed;    // Last usage timestamp
  DateTime createdAt;    // Creation timestamp
  DateTime updatedAt;    // Last update timestamp
}
```

**Key Methods:**
- `fromMap()/toMap()` - Database serialization
- `canBeUsedForContext()` - Privacy validation
- `updateUsage()` - Tracks usage statistics

**File:** `user_bio.dart`

**Purpose:** Aggregated biographical profile with insight management

```dart
class UserBio {
  String id;              // UUID identifier
  String userId;          // User identification
  DateTime createdAt;     // Profile creation
  DateTime updatedAt;     // Last update
  bool isEnabled;         // Privacy control
  List<BiographicalInsight> insights; // Collected insights
}
```

**Key Methods:**
- `getInsightsByCategory()` - Filter insights by category
- `getInsightsByPrivacyLevel()` - Filter by privacy level
- `generateContextForProphet()` - Create personalized context
- `getStatistics()` - Usage and confidence analytics

**Critical Implementation Note:** The `generateContextForProphet()` method only uses public/personal insights and formats them for natural integration into prophet responses.

### 4. Database Extension - `lib/services/database_service.dart`

**New Tables Added:**

**user_bio Table:**

```sql
CREATE TABLE user_bio (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_enabled INTEGER NOT NULL DEFAULT 1,
  total_insights INTEGER DEFAULT 0,
  last_context_generation INTEGER
);
```

**biographical_insights Table:**

```sql
CREATE TABLE biographical_insights (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  category TEXT NOT NULL,
  content TEXT NOT NULL,
  privacy_level INTEGER NOT NULL,
  confidence_score REAL NOT NULL,
  source_context TEXT,
  usage_count INTEGER DEFAULT 0,
  last_used INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Indexes for Performance:**

```sql
CREATE INDEX idx_bio_user_id ON user_bio(user_id);
CREATE INDEX idx_insights_user_id ON biographical_insights(user_id);
CREATE INDEX idx_insights_category ON biographical_insights(category);
CREATE INDEX idx_insights_privacy ON biographical_insights(privacy_level);
```

**Critical Implementation Note:** The database extension maintains compatibility with existing vision storage system. Privacy levels are stored as integers for efficient querying.

### 5. Bio Storage Service - `lib/services/bio/bio_storage_service.dart`

**Architecture:**
- **Pattern** - Singleton with lazy initialization
- **Dependencies** - DatabaseService, PrivacyFilterService, AppLogger
- **Error Handling** - Comprehensive try-catch with logging

**Core Operations:**

**User Bio Management:**
- `initializeUserBio()` - Create/retrieve user bio record
- `updateUserBio()` - Update profile metadata
- `disableUserBio()/enableUserBio()` - Privacy controls

**Insight Management:**
- `addInsight()` - Store new insights with privacy validation
- `updateInsight()` - Modify existing insights
- `deleteInsight()` - Remove insights (respects privacy)
- `getInsightsByCategory()` - Filtered retrieval

**Context Generation:**
- `generateContextForProphet()` - Create personalized context
- `getRecentInsights()` - Time-based filtering
- `getInsightStatistics()` - Analytics for optimization

**Privacy Enforcement:**

```dart
Future<String> addInsight({
  required String content,
  required String category,
  String? sourceContext,
  String? userId,
}) async {
  // 1. Classify privacy level using AI
  final privacyLevel = await _privacyFilter.analyzePrivacyLevel(content);
  
  // 2. Reject if not storable
  if (!privacyLevel.canStore) {
    throw Exception('Content classified as ${privacyLevel.name} - not storable');
  }
  
  // 3. Store with full metadata
  // ... storage logic
}
```

**Critical Implementation Note:** Every insight goes through privacy classification before storage. The system actively rejects sensitive/confidential data.

## Integration Points

**Existing Systems:**
- **AIServiceManager** - Used by privacy filter for content analysis
- **DatabaseService** - Extended with bio tables, maintains existing functionality
- **AppLogger** - Integrated throughout for debugging and monitoring

**Future Integration (Phase 2):**
- **Vision Integration Service** - Will trigger bio analysis after prophet responses
- **Prophet Response Generation** - Will incorporate bio context for personalization

## Configuration Requirements

**Environment Variables:**
No additional environment variables required - uses existing Azure OpenAI configuration.

**Dependencies:**
All bio system dependencies are already in pubspec.yaml:
- `sqflite` - Database operations
- `uuid` - Unique identifier generation
- Existing AI service infrastructure

## Privacy Compliance

**Data Handling:**
1. **Collection** - Only after explicit user interaction
2. **Classification** - AI-powered privacy analysis
3. **Storage** - Only public/personal data stored locally
4. **Usage** - Only stored data used for personalization
5. **Deletion** - Full user bio deletion available

**User Controls:**
- **Bio Enable/Disable** - Users can turn off bio collection
- **Data Deletion** - Complete profile deletion available
- **Transparency** - Users can view collected insights (future feature)

## Critical Implementation Notes for Phase 2

**Service Integration Pattern:**
The bio system should integrate with the existing vision integration service at the response processing stage, not during the initial API call.

**Context Integration Strategy:**
Bio context should be added to the prophet prompt as background information, not as explicit instructions, to maintain natural response flow.

**Error Handling Philosophy:**
Bio system errors should never break prophet interactions - always fail gracefully with logging.

**Privacy Validation Points:**
Every bio operation should validate privacy levels. Never assume data is safe to store or use.

## Phase 2 Roadmap

**Immediate Next Steps:**
1. **Integration with Vision Service** - Hook bio analysis into existing prophet interaction flow
2. **Real-time Analysis Agent** - Automatic Q&A analysis and insight extraction
3. **Context Integration** - Modify prophet response generation to include bio context
4. **Basic Testing** - Unit tests for core functionality

**Implementation Priority:**
1. Create bio analysis agent service
2. Integrate with existing vision integration service
3. Modify prophet response generation
4. Add basic error handling and monitoring

**Service Integration Example:**

```dart
// Get the bio storage service
final bioService = BioStorageService();

// Add insight after prophet interaction
await bioService.addInsight(
  content: 'User interested in ancient history',
  category: 'interests',
  sourceContext: 'Asked about Roman Empire',
  userId: currentUserId,
);

// Generate context for prophet response
final context = await bioService.generateContextForProphet(
  userId: currentUserId,
  maxInsights: 5,
);
```

---

**Status:** Phase 1 Complete - Ready for Phase 2 Implementation

**Next Phase:** Implement real-time bio analysis agent and integrate with existing prophet interaction flow.
