import 'package:flutter/material.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/models/vision_feedback.dart';
import 'package:profet_ai/widgets/vision_book/vision_card.dart';

class VisionSearchDelegate extends SearchDelegate<Vision?> {
  final List<Vision> visions;
  final Function(Vision) onVisionTap;
  final Function(Vision) onVisionDelete;
  final Function(Vision, FeedbackType) onFeedbackUpdate;

  VisionSearchDelegate({
    required this.visions,
    required this.onVisionTap,
    required this.onVisionDelete,
    required this.onFeedbackUpdate,
  });

  @override
  String get searchFieldLabel => 'Search visions...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
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
          'Start typing to search your visions...',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
      );
    }

    final filteredVisions = visions.where((vision) {
      final queryLower = query.toLowerCase();
      return vision.title.toLowerCase().contains(queryLower) ||
             vision.answer.toLowerCase().contains(queryLower) ||
             (vision.question?.toLowerCase().contains(queryLower) ?? false);
    }).toList();

    if (filteredVisions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              'No visions found',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVisions.length,
      itemBuilder: (context, index) {
        final vision = filteredVisions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VisionCard(
            vision: vision,
            onTap: () => onVisionTap(vision),
            onDelete: () => onVisionDelete(vision),
            onFeedbackUpdate: (feedbackType) => onFeedbackUpdate(vision, feedbackType),
          ),
        );
      },
    );
  }
}
