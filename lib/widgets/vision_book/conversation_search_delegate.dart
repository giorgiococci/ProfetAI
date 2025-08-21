import 'package:flutter/material.dart';
import 'package:orakl/models/conversation/conversation.dart';
import 'package:orakl/models/conversation/conversation_message.dart';
import 'package:orakl/widgets/vision_book/conversation_card.dart';

/// Search delegate for conversations in the conversation book
class ConversationSearchDelegate extends SearchDelegate<Conversation?> {
  final List<Conversation> conversations;
  final Map<int, List<ConversationMessage>> conversationMessages;
  final Function(Conversation) onConversationTap;
  final Function(Conversation) onConversationDelete;

  ConversationSearchDelegate({
    required this.conversations,
    required this.conversationMessages,
    required this.onConversationTap,
    required this.onConversationDelete,
  });

  @override
  String get searchFieldLabel => 'Search conversations...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search your conversations...',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final searchResults = conversations.where((conversation) {
      final titleMatch = conversation.title.toLowerCase().contains(query.toLowerCase());
      
      // Also search in message content
      final messages = conversationMessages[conversation.id] ?? [];
      final messageMatch = messages.any((message) => 
          message.content.toLowerCase().contains(query.toLowerCase()));
      
      return titleMatch || messageMatch;
    }).toList();

    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No conversations found.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final conversation = searchResults[index];
          final messages = conversationMessages[conversation.id] ?? [];
          
          return ConversationCard(
            conversation: conversation,
            recentMessages: messages,
            onTap: () {
              close(context, conversation);
              onConversationTap(conversation);
            },
            onDelete: () {
              onConversationDelete(conversation);
            },
          );
        },
      ),
    );
  }
}
