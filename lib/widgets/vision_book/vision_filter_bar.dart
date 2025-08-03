import 'package:flutter/material.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/l10n/app_localizations.dart';
import 'package:profet_ai/prophet_localizations.dart';

class VisionFilterBar extends StatelessWidget {
  final VisionFilter currentFilter;
  final Function(VisionFilter) onFilterChanged;
  final int visionCount;

  const VisionFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.visionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildProphetFilter(context),
          const SizedBox(width: 8),
          _buildSortButton(context),
          const Spacer(),
          if (currentFilter.hasActiveFilters)
            IconButton(
              onPressed: () => onFilterChanged(VisionFilter()),
              icon: const Icon(
                Icons.clear_all,
                color: Colors.purple,
                size: 20,
              ),
              tooltip: AppLocalizations.of(context)!.clearFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildProphetFilter(BuildContext context) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: currentFilter.prophetTypes.isNotEmpty
              ? Colors.purple.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              currentFilter.prophetTypes.isEmpty 
                  ? AppLocalizations.of(context)!.allOracles
                  : AppLocalizations.of(context)!.oraclesSelected(currentFilter.prophetTypes.length),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
      onSelected: (value) {
        final newTypes = Set<String>.from(currentFilter.prophetTypes);
        if (newTypes.contains(value)) {
          newTypes.remove(value);
        } else {
          newTypes.add(value);
        }
        onFilterChanged(currentFilter.copyWith(prophetTypes: newTypes));
      },
      itemBuilder: (context) => [
        _buildProphetMenuItemAsync(context, 'mystic_prophet', 'mystic'),
        _buildProphetMenuItemAsync(context, 'chaotic_prophet', 'chaotic'),
        _buildProphetMenuItemAsync(context, 'cynical_prophet', 'cynical'),
        _buildProphetMenuItemAsync(context, 'roaster_prophet', 'roaster'),
      ],
    );
  }

  PopupMenuItem<String> _buildProphetMenuItemAsync(BuildContext context, String value, String prophetKey) {
    final isSelected = currentFilter.prophetTypes.contains(value);
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? Colors.purple : Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 8),
          FutureBuilder<String>(
            future: ProphetLocalizations.getName(context, prophetKey),
            builder: (context, snapshot) {
              final label = snapshot.data ?? _getProphetFallbackName(value);
              return Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.purple : Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getProphetFallbackName(String prophetType) {
    switch (prophetType) {
      case 'mystic_prophet':
        return 'Mystic Oracle';
      case 'chaotic_prophet':
        return 'Chaotic Oracle';
      case 'cynical_prophet':
        return 'Cynical Oracle';
      case 'roaster_prophet':
        return 'The Prophet Who Roasts';
      default:
        return 'Oracle';
    }
  }

  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<VisionSortBy>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: currentFilter.sortBy != VisionSortBy.dateDesc
              ? Colors.purple.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(context, currentFilter.sortBy),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
      onSelected: (sortBy) {
        onFilterChanged(currentFilter.copyWith(sortBy: sortBy));
      },
      itemBuilder: (context) => [
        _buildSortMenuItem(context, VisionSortBy.dateDesc, AppLocalizations.of(context)!.newestFirst),
        _buildSortMenuItem(context, VisionSortBy.dateAsc, AppLocalizations.of(context)!.oldestFirst),
        _buildSortMenuItem(context, VisionSortBy.titleAsc, AppLocalizations.of(context)!.titleAZ),
        _buildSortMenuItem(context, VisionSortBy.titleDesc, AppLocalizations.of(context)!.titleZA),
        _buildSortMenuItem(context, VisionSortBy.prophetType, AppLocalizations.of(context)!.byOracle),
      ],
    );
  }

  PopupMenuItem<VisionSortBy> _buildSortMenuItem(BuildContext context, VisionSortBy sortBy, String label) {
    final isSelected = currentFilter.sortBy == sortBy;
    return PopupMenuItem<VisionSortBy>(
      value: sortBy,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSelected ? Colors.purple : Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.purple : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(BuildContext context, VisionSortBy sortBy) {
    final localizations = AppLocalizations.of(context)!;
    switch (sortBy) {
      case VisionSortBy.dateDesc:
        return localizations.newestFirst;
      case VisionSortBy.dateAsc:
        return localizations.oldestFirst;
      case VisionSortBy.titleAsc:
        return localizations.titleAZ;
      case VisionSortBy.titleDesc:
        return localizations.titleZA;
      case VisionSortBy.prophetType:
        return localizations.byOracle;
    }
  }
}
