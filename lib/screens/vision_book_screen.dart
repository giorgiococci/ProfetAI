import 'package:flutter/material.dart';
import 'package:profet_ai/models/conversation/conversation.dart';
import 'package:profet_ai/models/conversation/conversation_message.dart';
import 'package:profet_ai/models/conversation_filter.dart';
import 'package:profet_ai/models/profet_manager.dart';
import 'package:profet_ai/services/conversation/conversation_storage_service.dart';
import 'package:profet_ai/widgets/vision_book/conversation_card.dart';
import 'package:profet_ai/widgets/vision_book/empty_conversations_widget.dart';
import 'package:profet_ai/widgets/vision_book/conversation_search_delegate.dart';
import 'package:profet_ai/l10n/app_localizations.dart';
import 'package:profet_ai/utils/theme_utils.dart';

class VisionBookScreen extends StatefulWidget {
  final Function(int conversationId, ProfetType prophetType)? onConversationSelected;
  
  const VisionBookScreen({
    super.key,
    this.onConversationSelected,
  });

  @override
  State<VisionBookScreen> createState() => _VisionBookScreenState();
}

class _VisionBookScreenState extends State<VisionBookScreen> {
  final ConversationStorageService _storageService = ConversationStorageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Conversation> _allConversations = [];
  List<Conversation> _filteredConversations = [];
  Map<int, List<ConversationMessage>> _conversationMessages = {};
  ConversationFilter _currentFilter = const ConversationFilter();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final conversations = await _storageService.getAllConversations(limit: 1000);
      
      // Load messages for each conversation
      final messages = <int, List<ConversationMessage>>{};
      for (final conversation in conversations) {
        if (conversation.id != null) {
          messages[conversation.id!] = await _storageService.getConversationMessages(conversation.id!);
        }
      }
      
      setState(() {
        _allConversations = conversations;
        _conversationMessages = messages;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading conversations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Conversation> filtered = List.from(_allConversations);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((conversation) {
        final titleMatch = conversation.title.toLowerCase().contains(query);
        
        // Also search in message content
        final messages = _conversationMessages[conversation.id] ?? [];
        final messageMatch = messages.any((message) => 
            message.content.toLowerCase().contains(query));
        
        return titleMatch || messageMatch;
      }).toList();
    }

    // Apply prophet type filter
    if (_currentFilter.prophetTypes.isNotEmpty) {
      filtered = filtered.where((conversation) =>
          _currentFilter.prophetTypes.contains(conversation.prophetType)).toList();
    }

    // Apply date range filter
    if (_currentFilter.startDate != null) {
      filtered = filtered.where((conversation) =>
          conversation.lastUpdatedAt.isAfter(_currentFilter.startDate!) ||
          conversation.lastUpdatedAt.isAtSameMomentAs(_currentFilter.startDate!)).toList();
    }
    if (_currentFilter.endDate != null) {
      filtered = filtered.where((conversation) =>
          conversation.lastUpdatedAt.isBefore(_currentFilter.endDate!) ||
          conversation.lastUpdatedAt.isAtSameMomentAs(_currentFilter.endDate!)).toList();
    }

    // Apply status filter
    if (_currentFilter.status != null) {
      filtered = filtered.where((conversation) =>
          conversation.status == _currentFilter.status).toList();
    }

    // Apply AI enabled filter
    if (_currentFilter.isAIEnabled != null) {
      filtered = filtered.where((conversation) =>
          conversation.isAIEnabled == _currentFilter.isAIEnabled).toList();
    }

    // Apply message count filters
    if (_currentFilter.minMessageCount != null) {
      filtered = filtered.where((conversation) =>
          conversation.messageCount >= _currentFilter.minMessageCount!).toList();
    }

    if (_currentFilter.maxMessageCount != null) {
      filtered = filtered.where((conversation) =>
          conversation.messageCount <= _currentFilter.maxMessageCount!).toList();
    }

    // Sort conversations by most recent message timestamp (not conversation lastUpdatedAt)
    // This ensures that only adding actual content moves conversations to the top
    filtered.sort((a, b) {
      final aMessages = _conversationMessages[a.id] ?? [];
      final bMessages = _conversationMessages[b.id] ?? [];
      
      // Get the most recent message timestamp for each conversation
      final aLatestMessageTime = aMessages.isNotEmpty 
          ? aMessages.map((m) => m.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : a.startedAt; // Fallback to conversation start time if no messages
          
      final bLatestMessageTime = bMessages.isNotEmpty 
          ? bMessages.map((m) => m.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : b.startedAt; // Fallback to conversation start time if no messages
      
      return bLatestMessageTime.compareTo(aLatestMessageTime);
    });

    setState(() {
      _filteredConversations = filtered;
    });
  }

  Future<void> _deleteConversation(Conversation conversation) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete "${conversation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteConversation(conversation.id!);
        await _loadConversations(); // Reload the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting conversation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: ConversationSearchDelegate(
        conversations: _allConversations,
        conversationMessages: _conversationMessages,
        onConversationTap: _openConversation,
        onConversationDelete: _deleteConversation,
      ),
    );
  }

  /// Opens a conversation for viewing/continuing
  Future<void> _openConversation(Conversation conversation) async {
    try {
      print('DEBUG: Opening conversation ID ${conversation.id} via callback');
      
      // Get the prophet type for this conversation
      final prophetType = ProfetManager.getProfetTypeFromString(conversation.prophetType);
      
      // Use callback if provided (when in main navigation)
      if (widget.onConversationSelected != null) {
        widget.onConversationSelected!(conversation.id!, prophetType);
        print('DEBUG: Conversation selection sent via callback');
      } else {
        // Fallback to pop with data (for when screen is pushed)
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop({
            'openConversation': true,
            'prophetType': prophetType,
            'conversationId': conversation.id,
          });
        }
      }
      
    } catch (e) {
      print('DEBUG: Error opening conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: ThemeUtils.getVisionBookDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove the back arrow
          title: Text(localizations.visionBookTitle), // Use default styling like Settings
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _openSearch,
              tooltip: 'Search conversations',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadConversations,
              tooltip: 'Refresh conversations',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _buildConversationList(),
      ),
    );
  }

  Widget _buildConversationList() {
    if (_filteredConversations.isEmpty) {
      return const EmptyConversationsWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        itemCount: _filteredConversations.length,
        itemBuilder: (context, index) {
          final conversation = _filteredConversations[index];
          final messages = _conversationMessages[conversation.id] ?? [];
          
          return ConversationCard(
            conversation: conversation,
            recentMessages: messages,
            onTap: () => _openConversation(conversation),
            onDelete: () => _deleteConversation(conversation),
          );
        },
      ),
    );
  }
}
