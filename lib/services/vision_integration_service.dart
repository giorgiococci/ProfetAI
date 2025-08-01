import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vision.dart';
import '../models/vision_feedback.dart';
import '../models/profet.dart';
import '../services/vision_storage_service.dart';
import '../utils/app_logger.dart';

/// Enhanced vision service that handles vision generation AND automatic storage
/// 
/// This service acts as a bridge between the existing vision generation flow
/// and the new vision storage system, providing seamless integration
class VisionIntegrationService {
  static const String _component = 'VisionIntegrationService';
  
  final VisionStorageService _storageService = VisionStorageService();
  
  // Singleton pattern
  static final VisionIntegrationService _instance = VisionIntegrationService._internal();
  factory VisionIntegrationService() => _instance;
  VisionIntegrationService._internal();

  /// Generate and automatically store a vision for a question
  Future<VisionResult> generateAndStoreQuestionVision({
    required BuildContext context,
    required Profet profet,
    required String question,
    required bool isAIEnabled,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Generating and storing question-based vision');
      AppLogger.logInfo(_component, 'Prophet: ${profet.name}, Question: $question');
      
      // Generate the vision content using existing flow
      String content;
      bool actuallyAIGenerated = false;
      
      if (isAIEnabled) {
        try {
          content = await profet.getAIPersonalizedResponse(question, context);
          actuallyAIGenerated = true;
          AppLogger.logInfo(_component, 'AI-generated response received');
        } catch (e) {
          AppLogger.logWarning(_component, 'AI failed, using fallback response');
          content = await profet.getLocalizedPersonalizedResponse(context, question);
          actuallyAIGenerated = false;
        }
      } else {
        content = await profet.getLocalizedPersonalizedResponse(context, question);
        actuallyAIGenerated = false;
      }
      
      // Generate AI-powered title
      AppLogger.logInfo(_component, 'Generating vision title');
      final title = await profet.generateVisionTitle(
        context,
        question: question,
        answer: content,
      );
      
      // Store the vision automatically with timeout
      Vision? storedVision;
      try {
        AppLogger.logDebug(_component, 'Attempting to store vision in database...');
        storedVision = await _storageService.storeVision(
          title: title,
          question: question,
          answer: content,
          prophetType: profet.type,
          isAIGenerated: actuallyAIGenerated,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.logWarning(_component, 'Database storage timed out after 5 seconds');
            throw TimeoutException('Database storage timed out', const Duration(seconds: 5));
          },
        );
        AppLogger.logInfo(_component, 'Vision stored successfully with ID: ${storedVision.id}');
      } catch (e) {
        AppLogger.logWarning(_component, 'Failed to store vision in database, continuing without storage: $e');
        // Create a temporary vision object for the UI
        storedVision = Vision(
          id: -1, // Negative ID indicates not stored
          title: title,
          question: question,
          answer: content,
          prophetType: profet.type.toString(),
          feedbackType: null,
          timestamp: DateTime.now(),
          isAIGenerated: actuallyAIGenerated,
        );
      }
      
      return VisionResult(
        content: content,
        vision: storedVision,
        isAIGenerated: actuallyAIGenerated,
      );
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate and store question vision', e);
      rethrow;
    }
  }

  /// Generate and automatically store a random vision
  Future<VisionResult> generateAndStoreRandomVision({
    required BuildContext context,
    required Profet profet,
    required bool isAIEnabled,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Generating and storing random vision');
      AppLogger.logInfo(_component, 'Prophet: ${profet.name}');
      
      // Generate the vision content using existing flow
      String content;
      bool actuallyAIGenerated = false;
      
      if (isAIEnabled) {
        try {
          content = await profet.getAIRandomVision(context);
          actuallyAIGenerated = true;
          AppLogger.logInfo(_component, 'AI-generated random vision received');
        } catch (e) {
          AppLogger.logWarning(_component, 'AI failed, using fallback random vision');
          final visions = await profet.getLocalizedRandomVisions(context);
          content = visions.isNotEmpty ? visions.first : 'Oracle is silent...';
          actuallyAIGenerated = false;
        }
      } else {
        final visions = await profet.getLocalizedRandomVisions(context);
        content = visions.isNotEmpty ? visions.first : 'Oracle is silent...';
        actuallyAIGenerated = false;
      }
      
      // Generate AI-powered title
      AppLogger.logInfo(_component, 'Generating vision title for random vision');
      final title = await profet.generateVisionTitle(
        context,
        answer: content,
      );
      
      // Store the vision automatically with timeout
      Vision? storedVision;
      try {
        AppLogger.logDebug(_component, 'Attempting to store random vision in database...');
        storedVision = await _storageService.storeVision(
          title: title,
          question: null, // No question for random visions
          answer: content,
          prophetType: profet.type,
          isAIGenerated: actuallyAIGenerated,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.logWarning(_component, 'Database storage timed out after 5 seconds');
            throw TimeoutException('Database storage timed out', const Duration(seconds: 5));
          },
        );
        AppLogger.logInfo(_component, 'Random vision stored successfully with ID: ${storedVision.id}');
      } catch (e) {
        AppLogger.logWarning(_component, 'Failed to store vision in database, continuing without storage: $e');
        // Create a temporary vision object for the UI
        storedVision = Vision(
          id: -1, // Negative ID indicates not stored
          title: title,
          question: null,
          answer: content,
          prophetType: profet.type.toString(),
          feedbackType: null,
          timestamp: DateTime.now(),
          isAIGenerated: actuallyAIGenerated,
        );
      }
      
      return VisionResult(
        content: content,
        vision: storedVision,
        isAIGenerated: actuallyAIGenerated,
      );
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate and store random vision', e);
      rethrow;
    }
  }

  /// Update feedback for a stored vision
  Future<bool> updateVisionFeedback({
    required int visionId,
    required FeedbackType feedbackType,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Updating feedback for vision $visionId to ${feedbackType.name}');
      
      final success = await _storageService.updateVisionFeedback(visionId, feedbackType);
      
      if (success) {
        AppLogger.logInfo(_component, 'Feedback updated successfully');
      } else {
        AppLogger.logWarning(_component, 'Failed to update feedback');
      }
      
      return success;
      
    } catch (e) {
      AppLogger.logError(_component, 'Error updating vision feedback', e);
      return false;
    }
  }

  /// Get the storage service for direct access if needed
  VisionStorageService get storageService => _storageService;

  /// Check if the integration service is healthy
  Future<bool> isServiceHealthy() async {
    return await _storageService.isServiceHealthy();
  }

  /// Close connections
  Future<void> close() async {
    await _storageService.close();
  }
}

/// Result of vision generation including storage information
class VisionResult {
  final String content;
  final Vision vision;
  final bool isAIGenerated;

  const VisionResult({
    required this.content,
    required this.vision,
    required this.isAIGenerated,
  });

  /// Get the stored vision ID
  int? get visionId => vision.id;

  /// Get the generated title
  String get title => vision.title;

  /// Check if this vision had a question
  bool get hasQuestion => vision.hasQuestion;

  /// Get the prophet type
  String get prophetType => vision.prophetType;
}
