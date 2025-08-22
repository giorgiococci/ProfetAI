import 'package:flutter/material.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/vision_feedback.dart';
import '../../models/profet_manager.dart';
import '../../l10n/app_localizations.dart';

/// Widget for displaying individual message bubbles in conversations
/// Supports user and prophet messages with different styling and feedback options
class MessageBubble extends StatelessWidget {
  final ConversationMessage message;
  final ProfetType prophetType;
  final String? prophetImagePath;
  final Function(FeedbackType)? onFeedbackUpdate;
  final bool showFeedback;
  final bool isCompact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.prophetType,
    this.prophetImagePath,
    this.onFeedbackUpdate,
    this.showFeedback = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUserMessage;
    final isProphet = message.isProphetMessage;
    final prophet = ProfetManager.getProfet(prophetType);
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isCompact ? 2 : 4,
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment: isUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          _buildMessageBubble(context, isUser, prophet),
          // Show feedback section for prophet messages when conditions are met
          if (isProphet && showFeedback && onFeedbackUpdate != null)
            _buildFeedbackSection(),
          if (!isCompact)
            _buildTimestamp(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isUser, dynamic prophet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * (isCompact ? 0.85 : 0.75);
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: _getBubbleColor(isUser, prophet),
          borderRadius: _getBubbleBorderRadius(isUser),
          border: Border.all(
            color: _getBorderColor(isUser, prophet),
            width: 1,
          ),
          boxShadow: isCompact ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && !isCompact)
              _buildProphetHeader(prophet),
            _buildMessageContent(),
            if (message.isAIGenerated && !isUser && !isCompact)
              _buildAIIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProphetHeader(dynamic prophet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use prophet image as avatar if available, otherwise use icon
          prophetImagePath != null && prophetImagePath!.isNotEmpty
              ? CircleAvatar(
                  radius: 10,
                  backgroundColor: prophet.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: AssetImage(prophetImagePath!),
                )
              : Icon(
                  prophet.icon,
                  size: 14,
                  color: prophet.primaryColor,
                ),
          const SizedBox(width: 6),
          Text(
            prophet.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: prophet.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return SelectableText(
      message.content,
      style: TextStyle(
        color: Colors.white,
        fontSize: isCompact ? 14 : 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildAIIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.aiGenerated,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to right
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFeedbackButton(
            emoji: '🌟',
            type: FeedbackType.positive,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildFeedbackButton(
            emoji: '🪨',
            type: FeedbackType.negative,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildFeedbackButton(
            emoji: '🐸',
            type: FeedbackType.funny,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required String emoji,
    required FeedbackType type,
    required Color color,
  }) {
    final isSelected = message.feedbackType == type;
    
    return GestureDetector(
      onTap: () => onFeedbackUpdate?.call(type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.3) 
              : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 16,
            shadows: isSelected ? [
              Shadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 2,
              ),
            ] : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(message.timestamp);
    final localizations = AppLocalizations.of(context)!;
    
    String timeText;
    if (difference.inDays > 0) {
      timeText = localizations.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      timeText = localizations.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      timeText = localizations.minutesAgo(difference.inMinutes);
    } else {
      timeText = localizations.justNow;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        timeText,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Color _getBubbleColor(bool isUser, dynamic prophet) {
    if (isUser) {
      return Colors.blue.withValues(alpha: 0.15);
    } else {
      return prophet.primaryColor.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor(bool isUser, dynamic prophet) {
    if (isUser) {
      return Colors.blue.withValues(alpha: 0.3);
    } else {
      return prophet.primaryColor.withValues(alpha: 0.3);
    }
  }

  BorderRadius _getBubbleBorderRadius(bool isUser) {
    if (isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      );
    }
  }
}
