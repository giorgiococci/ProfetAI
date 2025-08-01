import 'package:flutter/material.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/l10n/app_localizations.dart';

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
      child: Column(
        children: [
          Row(
            children: [
              _buildProphetFilter(context),
              const SizedBox(width: 8),
              _buildSortButton(context),
              const Spacer(),
              if (currentFilter.hasActiveFilters)
                TextButton(
                  onPressed: () => onFilterChanged(VisionFilter()),
                  child: Text(
                    AppLocalizations.of(context)!.clearFilters,
                    style: const TextStyle(color: Colors.purple),
                  ),
                ),
            ],
          ),
          if (currentFilter.hasActiveFilters) ...[
            const SizedBox(height: 8),
            _buildActiveFilters(context),
          ],
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
        _buildProphetMenuItem('mystic_prophet', 'Mystic Oracle'),
        _buildProphetMenuItem('chaotic_prophet', 'Chaotic Oracle'),
        _buildProphetMenuItem('cynical_prophet', 'Cynical Oracle'),
      ],
    );
  }

  PopupMenuItem<String> _buildProphetMenuItem(String value, String label) {
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

  Widget _buildActiveFilters(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        if (currentFilter.prophetTypes.isNotEmpty)
          for (String prophetType in currentFilter.prophetTypes)
            _buildFilterChip(
              _getProphetDisplayName(prophetType),
              () {
                final newTypes = Set<String>.from(currentFilter.prophetTypes);
                newTypes.remove(prophetType);
                onFilterChanged(currentFilter.copyWith(prophetTypes: newTypes));
              },
            ),
        if (currentFilter.sortBy != VisionSortBy.dateDesc)
          _buildFilterChip(
            'Sort: ${_getSortLabel(context, currentFilter.sortBy)}',
            () => onFilterChanged(currentFilter.copyWith(sortBy: VisionSortBy.dateDesc)),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              color: Colors.white70,
              size: 14,
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

  String _getProphetDisplayName(String prophetType) {
    switch (prophetType) {
      case 'mystic_prophet':
        return 'Mystic';
      case 'chaotic_prophet':
        return 'Chaotic';
      case 'cynical_prophet':
        return 'Cynical';
      default:
        return prophetType;
    }
  }
}
