# ProfetAI Features Documentation

This document describes the key features implemented in ProfetAI and their specifications.

## Vision Storage and Management System

### Overview
The Vision Storage feature allows users to automatically store, review, and manage all their oracle visions and responses in a persistent local database. This feature enhances the user experience by providing a complete history of their spiritual journey with the prophets.

### Core Components

#### **Data Storage Architecture**
- **Technology**: SQLite for local data persistence
- **Storage Location**: Local device storage where the app is installed
- **Data Model**: Comprehensive vision records including:
  - User question (if present)
  - Timestamp of creation
  - Prophet used for the vision
  - Complete oracle answer/response
  - User feedback (positive/negative/funny)
  - AI-generated contextual title (max 30 characters)

#### **Automatic Vision Storage**
- **Behavior**: All visions are stored automatically upon generation
- **Scope**: Includes both:
  - Question-based responses (when user asks specific questions)
  - Random visions (spontaneous oracle insights)
- **Integration**: Seamlessly integrated with existing vision generation workflow

### Prophet-Specific Title Generation

#### **Implementation Approach**
- Each prophet class overrides a new `generateVisionTitle()` method
- Uses AI prompts that incorporate both user question and oracle answer as context
- Applies each prophet's unique personality and style to title creation
- Generates titles immediately during the vision storage process

#### **Prophet Title Characteristics**
- **Mystic Prophet**: Mystical, cosmic, and spiritual themes reflecting ancient wisdom
- **Chaotic Prophet**: Wild, unpredictable, and energetic themes embracing chaos
- **Cynical Prophet**: Realistic, direct, and sometimes harsh themes focused on truth

#### **Technical Requirements**
- Maximum 30 characters per title
- Context-aware generation based on actual content
- No hardcoded prefixes or templates
- Maintains prophet personality consistency

### Vision Book Screen

#### **User Interface Design**
- **Layout**: List view with card-based presentation
- **Card Content**:
  - AI-generated title (prominent display)
  - Prophet image (visual identification)
  - Content preview (truncated oracle response)
- **Interaction**: Tap to view complete vision details including full answer and original question

#### **Filtering and Search Capabilities**
- **Prophet Filter**: Show visions from specific oracles only
- **Feedback Filter**: Filter by user feedback type (positive/negative/funny)
- **Date Range Filter**: Show visions from specific time periods
- **Content Search**: Search functionality across titles and vision content
- **Question Type Filter**: Toggle between question-based responses and random visions
- **Sorting**: Default order by timestamp descending (newest first)

#### **Vision Details View**
- Complete oracle response display
- Original user question (if applicable)
- Prophet information and styling
- Feedback status and history
- Timestamp and metadata
- Individual vision deletion option

### Data Management Features

#### **Vision Deletion**
- **Individual Deletion**: Remove specific visions from the vision book screen
- **Bulk Deletion**: "Delete All Vision Data" button in user profile settings
- **Confirmation Dialogs**: Prevent accidental data loss
- **Cascading Cleanup**: Remove associated feedback and metadata

#### **Feedback System Integration**
- Existing feedback system integrated into vision storage
- Feedback data linked to specific stored visions
- Historical feedback tracking and analysis
- Feedback modification capabilities

### Technical Integration Points

#### **Database Schema**
```sql
CREATE TABLE visions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  question TEXT,
  answer TEXT NOT NULL,
  prophet_type TEXT NOT NULL,
  feedback_type TEXT,
  timestamp INTEGER NOT NULL,
  is_ai_generated BOOLEAN DEFAULT 0
);
```

#### **Service Layer Updates**
- **Vision Storage Service**: New service for database operations
- **Enhanced Feedback Service**: Integration with vision storage
- **Prophet Service Updates**: Title generation capabilities
- **Migration Service**: Convert existing in-memory feedback to persistent storage

#### **User Experience Flow**
1. User interacts with oracle (question or random vision)
2. Oracle generates response using AI or fallback methods
3. Prophet generates contextual title using AI
4. Vision automatically stored in SQLite database
5. User can provide feedback (integrated with storage)
6. Vision appears in Vision Book with filtering capabilities
7. User can review, search, and manage stored visions

### Performance Considerations

#### **Database Optimization**
- Indexed timestamp and prophet_type columns for efficient filtering
- Pagination support for large vision collections
- Lazy loading of vision content in list views
- Efficient text search implementation

#### **Memory Management**
- Minimal memory footprint for vision list display
- On-demand loading of full vision content
- Proper disposal of database connections
- Cache management for frequently accessed data

### Privacy and Security

#### **Data Protection**
- All vision data stored locally on device
- No cloud synchronization or external data transmission
- Secure deletion ensuring data is unrecoverable
- User control over data retention and removal

#### **User Consent**
- Transparent communication about automatic storage
- Easy access to data management controls
- Clear deletion confirmation processes
- Privacy-first approach to personal spiritual data

### Future Enhancements

#### **Potential Extensions**
- Vision export functionality (JSON, text formats)
- Advanced analytics and insights on vision patterns
- Vision sharing capabilities (with user consent)
- Backup and restore functionality
- Cross-device synchronization (optional)
- Vision categorization and tagging system

---

*This feature enhances ProfetAI's value proposition by providing users with a comprehensive spiritual journal that grows with their journey, while maintaining complete privacy and user control over their personal oracle experiences.*
