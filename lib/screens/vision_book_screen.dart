import 'package:flutter/material.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/models/vision_feedback.dart';
import 'package:profet_ai/models/profet_manager.dart';
import 'package:profet_ai/services/vision_storage_service.dart';
import 'package:profet_ai/widgets/vision_book/vision_book_app_bar.dart';
import 'package:profet_ai/widgets/vision_book/vision_filter_bar.dart';
import 'package:profet_ai/widgets/vision_book/vision_card.dart';
import 'package:profet_ai/widgets/vision_book/empty_visions_widget.dart';
import 'package:profet_ai/widgets/vision_book/vision_search_delegate.dart';
import 'package:profet_ai/widgets/home/vision_dialog.dart';
import 'package:profet_ai/utils/notification_utils.dart';
import 'package:profet_ai/utils/theme_utils.dart';
import 'package:profet_ai/l10n/app_localizations.dart';

class VisionBookScreen extends StatefulWidget {
  const VisionBookScreen({super.key});

  @override
  State<VisionBookScreen> createState() => _VisionBookScreenState();
}

class _VisionBookScreenState extends State<VisionBookScreen> {
  final VisionStorageService _storageService = VisionStorageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Vision> _allVisions = [];
  List<Vision> _filteredVisions = [];
  VisionFilter _currentFilter = VisionFilter();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVisions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVisions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visions = await _storageService.getVisions(limit: 1000); // Get all visions
      setState(() {
        _allVisions = visions;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorLoadingVisions}: $e'),
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
    List<Vision> filtered = List.from(_allVisions);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vision) {
        final query = _searchQuery.toLowerCase();
        return vision.title.toLowerCase().contains(query) ||
               vision.answer.toLowerCase().contains(query) ||
               (vision.question?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply prophet type filter
    if (_currentFilter.prophetTypes.isNotEmpty) {
      filtered = filtered.where((vision) =>
          _currentFilter.prophetTypes.contains(vision.prophetType)).toList();
    }

    // Apply date range filter
    if (_currentFilter.startDate != null) {
      filtered = filtered.where((vision) =>
          vision.timestamp.isAfter(_currentFilter.startDate!) ||
          vision.timestamp.isAtSameMomentAs(_currentFilter.startDate!)).toList();
    }
    if (_currentFilter.endDate != null) {
      filtered = filtered.where((vision) =>
          vision.timestamp.isBefore(_currentFilter.endDate!) ||
          vision.timestamp.isAtSameMomentAs(_currentFilter.endDate!)).toList();
    }

    // Apply feedback filter
    if (_currentFilter.feedbackTypes.isNotEmpty) {
      filtered = filtered.where((vision) =>
          vision.feedbackType != null &&
          _currentFilter.feedbackTypes.contains(vision.feedbackType!)).toList();
    }

    // Apply question filter
    if (_currentFilter.hasQuestion != null) {
      filtered = filtered.where((vision) =>
          _currentFilter.hasQuestion! ? vision.question != null : vision.question == null).toList();
    }

    // Apply sorting
    switch (_currentFilter.sortBy) {
      case VisionSortBy.dateDesc:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case VisionSortBy.dateAsc:
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case VisionSortBy.titleAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case VisionSortBy.titleDesc:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case VisionSortBy.prophetType:
        filtered.sort((a, b) => a.prophetType.compareTo(b.prophetType));
        break;
    }

    setState(() {
      _filteredVisions = filtered;
    });
  }

  void _onFilterChanged(VisionFilter newFilter) {
    setState(() {
      _currentFilter = newFilter;
      _applyFilters();
    });
  }

  Future<void> _deleteVision(Vision vision) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteVision),
        content: Text(localizations.deleteVisionConfirm(vision.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteVision(vision.id!);
        await _loadVisions(); // Reload the list
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.visionDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.errorDeletingVision}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateVisionFeedback(Vision vision, FeedbackType feedbackType) async {
    try {
      await _storageService.updateVisionFeedback(vision.id!, feedbackType);
      await _loadVisions(); // Reload to get updated feedback
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.feedbackUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorUpdatingFeedback}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: VisionSearchDelegate(
        visions: _allVisions,
        onVisionTap: (vision) {
          Navigator.of(context).pop();
          _showVisionDetail(vision);
        },
        onVisionDelete: _deleteVision,
        onFeedbackUpdate: _updateVisionFeedback,
      ),
    );
  }

  /// Shows vision detail dialog using the same dialog as home screen
  Future<void> _showVisionDetail(Vision vision) async {
    try {
      // Get the prophet object from the stored prophet type
      final prophetType = _getProphetTypeFromString(vision.prophetType);
      final profet = ProfetManager.getProfet(prophetType);
      
      final localizations = AppLocalizations.of(context)!;
      
      // Create appropriate title based on whether it's a question or random vision
      final title = vision.question != null 
          ? localizations.oracleResponds(_getProphetDisplayName(vision.prophetType))
          : localizations.visionOf(_getProphetDisplayName(vision.prophetType));
      
      await VisionDialog.show(
        context: context,
        title: title,
        titleIcon: vision.question != null ? Icons.psychology_alt : Icons.auto_awesome,
        content: vision.answer,
        profet: profet,
        isAIEnabled: vision.isAIGenerated,
        question: vision.question,
        onFeedbackSelected: (feedbackType) {
          // Update feedback in the database
          _updateVisionFeedback(vision, feedbackType);
        },
        onSave: () {
          // Show save confirmation (vision is already saved)
          NotificationUtils.showSaveConfirmation(
            context: context,
            prophetColor: ThemeUtils.getProphetColor(prophetType),
            message: 'Vision "${vision.title}" is already in your Vision Book!',
          );
        },
        onShare: () {
          // Show share confirmation
          NotificationUtils.showShareConfirmation(
            context: context,
            prophetColor: ThemeUtils.getProphetColor(prophetType),
          );
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      // Handle any errors showing the dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing vision: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Convert prophet type string to ProfetType enum
  ProfetType _getProphetTypeFromString(String prophetType) {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
        return ProfetType.mistico;
      case 'chaotic_prophet':
        return ProfetType.caotico;
      case 'cynical_prophet':
        return ProfetType.cinico;
      default:
        return ProfetType.mistico;
    }
  }

  /// Get display name for prophet type
  String _getProphetDisplayName(String prophetType) {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
        return 'Mystic Oracle';
      case 'chaotic_prophet':
        return 'Chaotic Oracle';
      case 'cynical_prophet':
        return 'Cynical Oracle';
      default:
        return 'Oracle';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VisionBookAppBar(
        searchController: _searchController,
        onSearchTap: _openSearch,
        onRefreshTap: _loadVisions,
        visionCount: _filteredVisions.length,
        totalCount: _allVisions.length,
      ),
      body: Column(
        children: [
          VisionFilterBar(
            currentFilter: _currentFilter,
            onFilterChanged: _onFilterChanged,
            visionCount: _filteredVisions.length,
          ),
          Expanded(
            child: _buildVisionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredVisions.isEmpty) {
      return EmptyVisionsWidget(
        hasFilters: _currentFilter.hasActiveFilters || _searchQuery.isNotEmpty,
        onClearFilters: () {
          setState(() {
            _currentFilter = VisionFilter();
            _searchController.clear();
            _searchQuery = '';
            _applyFilters();
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVisions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredVisions.length,
        itemBuilder: (context, index) {
          final vision = _filteredVisions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: VisionCard(
              vision: vision,
              onTap: () => _showVisionDetail(vision),
              onDelete: () => _deleteVision(vision),
              onFeedbackUpdate: (feedbackType) => _updateVisionFeedback(vision, feedbackType),
            ),
          );
        },
      ),
    );
  }
}
