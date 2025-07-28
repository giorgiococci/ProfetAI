import 'package:flutter/material.dart';

class EmptyVisionsWidget extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const EmptyVisionsWidget({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.auto_stories_outlined,
              size: 80,
              color: Colors.white38,
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No visions match your filters' : 'No visions stored yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters 
                  ? 'Try adjusting your search criteria or clear filters to see all visions.'
                  : 'Start your mystical journey by asking the oracles for guidance.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onClearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
