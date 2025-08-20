import 'package:flutter/material.dart';
import 'package:orakl/models/conversation/conversation.dart';
import 'package:orakl/models/conversation/conversation_message.dart';
import 'package:orakl/models/profet_manager.dart';
import 'package:orakl/utils/theme_utils.dart';
import 'package:intl/intl.dart';

/// Card widget for displaying conversation summary in the conversation book
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final List<ConversationMessage> recentMessages;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.recentMessages,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final prophetType = _getProphetTypeFromString(conversation.prophetType);
    final profet = ProfetManager.getProfet(prophetType);
    final prophetColor = ThemeUtils.getProphetColor(prophetType);
    
    // Get the last user message for preview
    final lastUserMessage = recentMessages
        .where((msg) => msg.sender == MessageSender.user)
        .lastOrNull;
    
    // Get the last prophet message for preview  
    final lastProphetMessage = recentMessages
        .where((msg) => msg.sender == MessageSender.prophet)
        .lastOrNull;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      color: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: prophetColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with prophet info and actions
              Row(
                children: [
                  // Prophet avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: prophetColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: profet.profetImagePath != null
                          ? Image.asset(
                              profet.profetImagePath!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person,
                              color: prophetColor,
                              size: 20,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Conversation info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getProphetDisplayName(conversation.prophetType)} • ${conversation.messageCount} messages',
                          style: TextStyle(
                            color: prophetColor.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              if (lastUserMessage != null || lastProphetMessage != null) ...[
                const SizedBox(height: 16),
                // Last messages preview
                if (lastUserMessage != null) ...[
                  _buildMessagePreview(
                    'You',
                    lastUserMessage.content,
                    Colors.white70,
                    Icons.person,
                  ),
                  if (lastProphetMessage != null) const SizedBox(height: 8),
                ],
                if (lastProphetMessage != null) ...[
                  _buildMessagePreview(
                    _getProphetDisplayName(conversation.prophetType),
                    lastProphetMessage.content,
                    prophetColor.withOpacity(0.9),
                    Icons.auto_awesome,
                  ),
                ],
              ],
              
              const SizedBox(height: 12),
              // Footer with timestamp only
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(conversation.lastUpdatedAt),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagePreview(String sender, String content, Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ProfetType _getProphetTypeFromString(String prophetTypeString) {
    return ProfetManager.getProfetTypeFromString(prophetTypeString);
  }

  String _getProphetDisplayName(String prophetType) {
    final type = _getProphetTypeFromString(prophetType);
    final profet = ProfetManager.getProfet(type);
    return profet.name;
  }
}
