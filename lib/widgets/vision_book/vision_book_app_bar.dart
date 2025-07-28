import 'package:flutter/material.dart';

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
    return AppBar(
      title: const Text(
        'Vision Book',
        style: TextStyle(
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
          tooltip: 'Search visions',
        ),
        IconButton(
          onPressed: onRefreshTap,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
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
                    ? '$totalCount visions'
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
                    color: Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Filtered',
                    style: TextStyle(
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
