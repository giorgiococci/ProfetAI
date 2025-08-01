import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class VisionBookAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchTap;
  final VoidCallback onRefreshTap;
  final int visionCount;
  final int totalCount;

  const VisionBookAppBar({
    super.key,
    required this.searchController,
    required this.onSearchTap,
    required this.onRefreshTap,
    required this.visionCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return AppBar(
      title: Text(
        localizations.visionBookTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          onPressed: onSearchTap,
          icon: const Icon(Icons.search),
          tooltip: localizations.searchVisions,
        ),
        IconButton(
          onPressed: onRefreshTap,
          icon: const Icon(Icons.refresh),
          tooltip: localizations.refreshVisions,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                visionCount == totalCount
                    ? '$totalCount ${totalCount == 1 ? 'vision' : 'visions'}'
                    : '$visionCount of $totalCount visions',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (visionCount != totalCount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    localizations.filtered,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}
