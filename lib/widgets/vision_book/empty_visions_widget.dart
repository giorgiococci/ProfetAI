import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;
    
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
              hasFilters ? localizations.noVisionsMatchFilters : localizations.noVisionsStoredYet,
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
                  ? localizations.tryAdjustingFilters
                  : localizations.startMysticalJourney,
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
                  backgroundColor: Colors.purple.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(localizations.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
