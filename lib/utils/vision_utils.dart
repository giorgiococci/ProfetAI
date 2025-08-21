import 'package:flutter/material.dart';
import '../../models/vision_feedback.dart';
import '../../services/feedback_service.dart';
import '../utils/notification_utils.dart';

/// Business logic utilities for vision and feedback handling
/// Encapsulates common business operations and workflows
class VisionUtils {

  /// Handles the complete feedback workflow
  static Future<void> handleFeedback({
    required BuildContext context,
    required profet,
    required FeedbackType feedbackType,
    required String visionContent,
    String? question,
    VoidCallback? onComplete,
  }) async {
    try {
      // Create feedback using the prophet's custom localized texts
      final feedback = await profet.createFeedback(
        context,
        type: feedbackType,
        visionContent: visionContent,
        question: question,
      );

      // Save feedback
      await FeedbackService().saveFeedback(feedback);

      // Check mounted before using context
      if (!context.mounted) return;

      // Show feedback confirmation
      NotificationUtils.showFeedbackConfirmation(
        context: context,
        feedback: feedback,
        prophetColor: profet.primaryColor,
      );

      // Call completion callback
      onComplete?.call();
      
    } catch (e) {
      if (context.mounted) {
        NotificationUtils.showError(
          context: context,
          message: 'Failed to save feedback: $e',
        );
      }
    }
  }

  /// Gets AI or fallback content for questions
  static Future<String> getQuestionResponse({
    required BuildContext context,
    required profet,
    required String question,
    required Function(BuildContext, dynamic) showLoadingDialog,
    required Function(BuildContext) dismissLoadingDialog,
  }) async {
    final isAIEnabled = profet.runtimeType.toString().contains('Profet') ? 
        (profet as dynamic).isAIEnabled : false;

    if (isAIEnabled) {
      await showLoadingDialog(context, profet);

      try {
        if (context.mounted) {
          final content = await profet.getAIPersonalizedResponse(question, context);
          if (context.mounted) dismissLoadingDialog(context);
          return content;
        }
      } catch (e) {
        if (context.mounted) dismissLoadingDialog(context);
        // Use localized fallback response
        if (context.mounted) {
          return await profet.getLocalizedPersonalizedResponse(context, question);
        }
      }
    } else {
      // Use localized fallback response when AI is disabled
      if (context.mounted) {
        return await profet.getLocalizedPersonalizedResponse(context, question);
      }
    }
    
    return 'Unable to generate response';
  }

  /// Gets AI or fallback content for random visions
  static Future<String> getRandomVision({
    required BuildContext context,
    required profet,
    required Function(BuildContext, dynamic) showLoadingDialog,
    required Function(BuildContext) dismissLoadingDialog,
  }) async {
    final isAIEnabled = profet.runtimeType.toString().contains('Profet') ? 
        (profet as dynamic).isAIEnabled : false;

    if (isAIEnabled) {
      await showLoadingDialog(context, profet);

      try {
        if (context.mounted) {
          final content = await profet.getAIRandomVision(context);
          if (context.mounted) dismissLoadingDialog(context);
          return content;
        }
      } catch (e) {
        if (context.mounted) dismissLoadingDialog(context);
        // Use localized random visions as fallback
        if (context.mounted) {
          final visions = await profet.getLocalizedRandomVisions(context);
          return visions.isNotEmpty ? visions.first : 'Oracle is silent...';
        }
      }
    } else {
      // Use localized random visions when AI is disabled
      if (context.mounted) {
        final visions = await profet.getLocalizedRandomVisions(context);
        return visions.isNotEmpty ? visions.first : 'Oracle is silent...';
      }
    }
    
    return 'Unable to generate vision';
  }

  /// Validates question input and shows appropriate error
  static bool validateQuestionInput({
    required BuildContext context,
    required String question,
    required String errorMessage,
  }) {
    if (question.trim().isEmpty) {
      NotificationUtils.showError(
        context: context,
        message: errorMessage,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  /// Formats vision content for display
  static String formatVisionContent(String content) {
    if (content.isEmpty) return content;
    
    // Ensure first letter is capitalized
    final trimmed = content.trim();
    if (trimmed.isEmpty) return trimmed;
    
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  /// Determines if a vision should use AI based on profet type and availability
  static bool shouldUseAI(dynamic profet) {
    try {
      return profet.isAIEnabled;
    } catch (e) {
      return false; // Fallback to false if property doesn't exist
    }
  }

  /// Gets the appropriate loading message for a profet type
  static Future<String> getLoadingMessage(BuildContext context, dynamic profet) async {
    try {
      // Try to get profet-specific loading message
      final profetTypeName = profet.runtimeType.toString().toLowerCase();
      if (profetTypeName.contains('caotico')) {
        return 'Chaos is consulting the void...';
      } else if (profetTypeName.contains('mistico')) {
        return 'The mystic communes with ancient wisdom...';
      } else if (profetTypeName.contains('cinico')) {
        return 'The cynic contemplates harsh truths...';
      }
      return 'Consulting the oracle...';
    } catch (e) {
      return 'Loading...';
    }
  }

  /// Creates a standardized vision result object
  static Map<String, dynamic> createVisionResult({
    required String content,
    required bool isAIGenerated,
    required String prophetName,
    String? question,
    DateTime? timestamp,
  }) {
    return {
      'content': formatVisionContent(content),
      'isAIGenerated': isAIGenerated,
      'prophetName': prophetName,
      'question': question,
      'timestamp': timestamp ?? DateTime.now(),
      'type': question != null ? 'question_response' : 'random_vision',
    };
  }

  /// Handles save action for visions
  static void handleSaveAction({
    required BuildContext context,
    required dynamic profet,
    String message = 'Visione salvata nel Libro delle Visioni',
    VoidCallback? onComplete,
  }) {
    NotificationUtils.showSaveConfirmation(
      context: context,
      prophetColor: profet.primaryColor,
      message: message,
    );
    onComplete?.call();
  }

  /// Handles share action for visions
  static void handleShareAction({
    required BuildContext context,
    required dynamic profet,
    String message = 'Preparando la condivisione della visione...',
    VoidCallback? onComplete,
  }) {
    NotificationUtils.showShareConfirmation(
      context: context,
      prophetColor: profet.secondaryColor,
      message: message,
    );
    onComplete?.call();
  }

  /// Checks if the widget is still mounted before performing actions
  static bool isContextValid(BuildContext? context) {
    return context != null && context.mounted;
  }

  /// Safe navigation that checks context validity
  static void safeNavigate(BuildContext? context, VoidCallback? action) {
    if (isContextValid(context) && action != null) {
      action();
    }
  }

  /// Gets all feedback types for a profet
  static List<FeedbackType> getAvailableFeedbackTypes() {
    return FeedbackType.values;
  }

  /// Determines if a vision can be saved
  static bool canSaveVision(String content) {
    return content.trim().isNotEmpty && content.trim().length > 10;
  }

  /// Determines if a vision can be shared
  static bool canShareVision(String content) {
    return canSaveVision(content); // Same criteria for now
  }

  /// Creates a shareable text format for visions
  static String createShareableText({
    required String content,
    required String prophetName,
    String? question,
  }) {
    final buffer = StringBuffer();
    
    if (question != null && question.isNotEmpty) {
      buffer.writeln('Question: $question');
      buffer.writeln('');
    }
    
    buffer.writeln('Oracle Response from $prophetName:');
    buffer.writeln('"$content"');
    buffer.writeln('');
    buffer.writeln('Generated by Orakl');
    
    return buffer.toString();
  }
}
