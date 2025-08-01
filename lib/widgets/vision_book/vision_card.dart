import 'package:flutter/material.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/models/vision_feedback.dart';
import 'package:profet_ai/models/profet_manager.dart';
import 'package:profet_ai/utils/theme_utils.dart';
import 'package:profet_ai/prophet_localizations.dart';
import 'package:profet_ai/l10n/app_localizations.dart';

class VisionCard extends StatelessWidget {
  final Vision vision;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(FeedbackType) onFeedbackUpdate;

  const VisionCard({
    super.key,
    required this.vision,
    required this.onTap,
    required this.onDelete,
    required this.onFeedbackUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final prophetType = _getProphetTypeFromString(vision.prophetType);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeUtils.getProphetColor(prophetType).withValues(alpha: 0.1),
                ThemeUtils.getProphetColor(prophetType).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, prophetType),
              const SizedBox(height: 8),
              _buildTitle(),
              if (vision.question != null) ...[
                const SizedBox(height: 8),
                _buildQuestion(),
              ],
              const SizedBox(height: 8),
              _buildPreview(),
              const SizedBox(height: 12),
              _buildFooter(context, prophetType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfetType prophetType) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ThemeUtils.getProphetColor(prophetType).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FutureBuilder<String>(
            future: _getProphetLocalizedName(context, vision.prophetType),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? _getDisplayName(vision.prophetType),
                style: TextStyle(
                  color: ThemeUtils.getProphetColor(prophetType),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.grey[600],
            size: 20,
          ),
          onSelected: (value) {
            switch (value) {
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.delete, 
                    style: const TextStyle(color: Colors.red)
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      vision.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildQuestion() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              vision.question!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Text(
      vision.answer,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white70,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context, ProfetType prophetType) {
    return Row(
      children: [
        _buildTimestamp(context),
        const Spacer(),
        _buildFeedbackButtons(),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(vision.timestamp);
    
    String timeString;
    if (difference.inDays > 0) {
      timeString = localizations.timeAgo('${difference.inDays}d');
    } else if (difference.inHours > 0) {
      timeString = localizations.timeAgo('${difference.inHours}h');
    } else if (difference.inMinutes > 0) {
      timeString = localizations.timeAgo('${difference.inMinutes}m');
    } else {
      timeString = localizations.justNow;
    }

    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: Colors.white54,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          timeString,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _feedbackButton(
          text: '🌟',
          type: FeedbackType.positive,
          color: Colors.green,
        ),
        const SizedBox(width: 4),
        _feedbackButton(
          text: '🪨',
          type: FeedbackType.negative,
          color: Colors.red,
        ),
        const SizedBox(width: 4),
        _feedbackButton(
          text: '🐸',
          type: FeedbackType.funny,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _feedbackButton({
    required String text,
    required FeedbackType type,
    required Color color,
  }) {
    final isSelected = vision.feedbackType == type;
    
    return GestureDetector(
      onTap: () => onFeedbackUpdate(type),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.white54,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? color : Colors.white54,
          ),
        ),
      ),
    );
  }

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

  String _getDisplayName(String prophetType) {
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

  Future<String> _getProphetLocalizedName(BuildContext context, String prophetType) async {
    final prophetKey = _getProphetLocalizationKey(prophetType);
    try {
      return await ProphetLocalizations.getName(context, prophetKey);
    } catch (e) {
      return _getDisplayName(prophetType); // Fallback to hardcoded names
    }
  }

  String _getProphetLocalizationKey(String prophetType) {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
        return 'mystic';
      case 'chaotic_prophet':
        return 'chaotic';
      case 'cynical_prophet':
        return 'cynical';
      default:
        return 'mystic';
    }
  }
}
