import 'package:flutter/material.dart';
import '../../services/bio/bio_storage_service.dart';
import '../../models/bio/biographical_insight.dart';
import '../../utils/privacy/privacy_levels.dart';
import '../../widgets/home/error_display_widget.dart';

class BioManagementScreen extends StatefulWidget {
  const BioManagementScreen({super.key});

  @override
  State<BioManagementScreen> createState() => _BioManagementScreenState();
}

class _BioManagementScreenState extends State<BioManagementScreen>
    with TickerProviderStateMixin {
  final BioStorageService _bioStorageService = BioStorageService();
  late TabController _tabController;
  
  List<BiographicalInsight> _insights = [];
  bool _isLoading = false;
  String? _error;
  
  // Filter and sort options
  String _selectedSource = 'All';
  String _selectedSort = 'Date';
  PrivacyLevel? _selectedPrivacyLevel;
  
  // Statistics
  int _totalInsights = 0;
  int _publicInsights = 0;
  int _sensitiveInsights = 0;
  int _privateInsights = 0;
  int _highlyPrivateInsights = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user bio with insights
      final userBio = await _bioStorageService.getUserBio();
      final insights = userBio?.insights ?? [];
      
      if (mounted) {
        setState(() {
          _insights = insights;
          _calculateStatistics();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load insights: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _calculateStatistics() {
    _totalInsights = _insights.length;
    _publicInsights = _insights.where((i) => i.privacyLevel == PrivacyLevel.public).length;
    _sensitiveInsights = _insights.where((i) => i.privacyLevel == PrivacyLevel.sensitive).length;
    _privateInsights = _insights.where((i) => i.privacyLevel == PrivacyLevel.personal).length;
    _highlyPrivateInsights = _insights.where((i) => i.privacyLevel == PrivacyLevel.confidential).length;
  }

  List<BiographicalInsight> get _filteredAndSortedInsights {
    List<BiographicalInsight> filtered = _insights;
    
    // Filter by source
    if (_selectedSource != 'All') {
      filtered = filtered.where((insight) => insight.extractedFrom == _selectedSource).toList();
    }
    
    // Filter by privacy level
    if (_selectedPrivacyLevel != null) {
      filtered = filtered.where((insight) => insight.privacyLevel == _selectedPrivacyLevel).toList();
    }
    
    // Sort
    switch (_selectedSort) {
      case 'Date':
        filtered.sort((a, b) => b.extractedAt.compareTo(a.extractedAt));
        break;
      case 'Privacy':
        filtered.sort((a, b) => a.privacyLevel.index.compareTo(b.privacyLevel.index));
        break;
      case 'Source':
        filtered.sort((a, b) => a.extractedFrom.compareTo(b.extractedFrom));
        break;
      case 'Content':
        filtered.sort((a, b) => a.content.compareTo(b.content));
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biographical Insights'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Insights'),
            Tab(text: 'Settings'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInsightsTab(),
          _buildSettingsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        errorMessage: _error!,
      );
    }

    final filteredInsights = _filteredAndSortedInsights;

    return Column(
      children: [
        _buildFiltersRow(),
        Expanded(
          child: filteredInsights.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredInsights.length,
                  itemBuilder: (context, index) {
                    return _buildInsightCard(filteredInsights[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFiltersRow() {
    final uniqueSources = ['All', ..._insights.map((i) => i.extractedFrom).toSet().toList()];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSource,
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    isDense: true,
                  ),
                  items: uniqueSources.map<DropdownMenuItem<String>>((String source) {
                    return DropdownMenuItem<String>(
                      value: source,
                      child: Text(source),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSource = value ?? 'All';
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Date', child: Text('Date')),
                    DropdownMenuItem(value: 'Privacy', child: Text('Privacy')),
                    DropdownMenuItem(value: 'Source', child: Text('Source')),
                    DropdownMenuItem(value: 'Content', child: Text('Content')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value ?? 'Date';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PrivacyLevel?>(
            value: _selectedPrivacyLevel,
            decoration: const InputDecoration(
              labelText: 'Privacy Level',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Levels')),
              ...PrivacyLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(_getPrivacyLevelName(level)),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPrivacyLevel = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BiographicalInsight insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getPrivacyIcon(insight.privacyLevel),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteInsight(insight),
                  tooltip: 'Delete insight',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    insight.extractedFrom,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    _getPrivacyLevelName(insight.privacyLevel),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getPrivacyLevelColor(insight.privacyLevel),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(insight.extractedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No insights found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start conversations with your prophets to generate biographical insights',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bio Collection',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Control how biographical information is collected from your conversations.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Bio Collection'),
                  subtitle: const Text('Allow extraction of biographical insights from conversations'),
                  value: true, // This would be connected to actual settings
                  onChanged: (value) {
                    // TODO: Implement settings toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('Auto-categorize Privacy'),
                  subtitle: const Text('Automatically classify insights by privacy level'),
                  value: true, // This would be connected to actual settings
                  onChanged: (value) {
                    // TODO: Implement settings toggle
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Management',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Insights'),
                  subtitle: const Text('Download your biographical data'),
                  onTap: () {
                    // TODO: Implement export functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Insights'),
                  subtitle: const Text('Permanently delete all biographical data'),
                  onTap: () => _confirmClearAllInsights(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsCard(),
        const SizedBox(height: 16),
        _buildPrivacyBreakdown(),
        const SizedBox(height: 16),
        _buildSourceBreakdown(),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$_totalInsights',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Total Insights',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_insights.map((i) => i.extractedFrom).toSet().length}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Sources',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildPrivacyRow('Public', _publicInsights, Colors.green),
            _buildPrivacyRow('Personal', _privateInsights, Colors.blue),
            _buildPrivacyRow('Sensitive', _sensitiveInsights, Colors.orange),
            _buildPrivacyRow('Confidential', _highlyPrivateInsights, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyRow(String label, int count, Color color) {
    final percentage = _totalInsights > 0 ? (count / _totalInsights * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text('$count ($percentage%)'),
        ],
      ),
    );
  }

  Widget _buildSourceBreakdown() {
    final sourceStats = <String, int>{};
    for (final insight in _insights) {
      sourceStats[insight.extractedFrom] = (sourceStats[insight.extractedFrom] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sources',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...sourceStats.entries.map((entry) {
              final percentage = _totalInsights > 0 
                  ? (entry.value / _totalInsights * 100).round() 
                  : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value} ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteInsight(BiographicalInsight insight) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Insight'),
        content: const Text('Are you sure you want to delete this insight?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (insight.id != null) {
          await _bioStorageService.deleteInsight(insight.id!);
          await _loadInsights(); // Refresh the list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Insight deleted')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete insight: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmClearAllInsights() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Insights'),
        content: const Text(
          'Are you sure you want to delete ALL biographical insights? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bioStorageService.deleteAllInsights();
        await _loadInsights(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All insights cleared')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear insights: $e')),
          );
        }
      }
    }
  }

  Widget _getPrivacyIcon(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.public:
        return const Icon(Icons.public, color: Colors.green, size: 20);
      case PrivacyLevel.personal:
        return const Icon(Icons.person_outline, color: Colors.blue, size: 20);
      case PrivacyLevel.sensitive:
        return const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 20);
      case PrivacyLevel.confidential:
        return const Icon(Icons.security, color: Colors.red, size: 20);
    }
  }

  String _getPrivacyLevelName(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.public:
        return 'Public';
      case PrivacyLevel.personal:
        return 'Personal';
      case PrivacyLevel.sensitive:
        return 'Sensitive';
      case PrivacyLevel.confidential:
        return 'Confidential';
    }
  }

  Color _getPrivacyLevelColor(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.public:
        return Colors.green.withOpacity(0.2);
      case PrivacyLevel.personal:
        return Colors.blue.withOpacity(0.2);
      case PrivacyLevel.sensitive:
        return Colors.orange.withOpacity(0.2);
      case PrivacyLevel.confidential:
        return Colors.red.withOpacity(0.2);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
