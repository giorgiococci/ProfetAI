/// Utility class for input validation and text processing
/// Provides static methods for common validation scenarios
class ValidationUtils {
  
  /// Validates if a string is not empty after trimming whitespace
  static bool isNotEmpty(String? text) {
    if (text == null) return false;
    return text.trim().isNotEmpty;
  }

  /// Validates if a string is empty after trimming whitespace
  static bool isEmpty(String? text) {
    return !isNotEmpty(text);
  }

  /// Cleans and trims text input
  static String cleanText(String? text) {
    if (text == null) return '';
    return text.trim();
  }

  /// Validates question input for oracle queries
  static String? validateQuestion(String? question) {
    if (question == null || question.trim().isEmpty) {
      return 'Please enter a question before consulting the oracle';
    }
    
    final cleaned = question.trim();
    if (cleaned.length < 3) {
      return 'Question must be at least 3 characters long';
    }
    
    if (cleaned.length > 500) {
      return 'Question must be less than 500 characters';
    }
    
    return null; // Valid
  }

  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null; // Valid
  }

  /// Validates password strength
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null; // Valid
  }

  /// Validates username format
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }
    
    final cleaned = username.trim();
    if (cleaned.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (cleaned.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(cleaned)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null; // Valid
  }

  /// Validates required text field
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null; // Valid
  }

  /// Validates text length
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String fieldName = 'Field',
  }) {
    if (value == null) return null;
    
    final length = value.trim().length;
    
    if (minLength != null && length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (maxLength != null && length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null; // Valid
  }

  /// Validates numeric input
  static String? validateNumeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null; // Valid
  }

  /// Validates integer input
  static String? validateInteger(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (int.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid integer';
    }
    
    return null; // Valid
  }

  /// Validates URL format
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'URL is required';
    }
    
    try {
      final uri = Uri.parse(url.trim());
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }
    
    return null; // Valid
  }

  /// Validates phone number format (basic validation)
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Please enter a valid phone number';
    }
    
    return null; // Valid
  }

  /// Validates that two fields match (useful for password confirmation)
  static String? validateMatch(String? value1, String? value2, {String fieldName = 'Field'}) {
    if (value1 != value2) {
      return '${fieldName}s do not match';
    }
    return null; // Valid
  }

  /// Checks if text contains profanity or inappropriate content
  static bool containsProfanity(String text) {
    // Basic profanity filter - in production, use a more comprehensive solution
    final profanityWords = ['badword1', 'badword2']; // Add actual words as needed
    final lowercaseText = text.toLowerCase();
    
    for (final word in profanityWords) {
      if (lowercaseText.contains(word)) {
        return true;
      }
    }
    
    return false;
  }

  /// Validates content for appropriateness
  static String? validateContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'Content is required';
    }
    
    if (containsProfanity(content)) {
      return 'Content contains inappropriate language';
    }
    
    return null; // Valid
  }

  /// Sanitizes text by removing special characters
  static String sanitizeText(String text) {
    // Remove special characters but keep basic punctuation
    return text.replaceAll(RegExp(r'[^\w\s\.\,\!\?\-]'), '');
  }

  /// Formats text for display (capitalizes first letter, trims)
  static String formatDisplayText(String text) {
    final cleaned = cleanText(text);
    if (cleaned.isEmpty) return cleaned;
    
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  /// Validates multiple fields at once
  static List<String> validateMultiple(Map<String, String?> fields, Map<String, String? Function(String?)> validators) {
    final errors = <String>[];
    
    fields.forEach((fieldName, value) {
      final validator = validators[fieldName];
      if (validator != null) {
        final error = validator(value);
        if (error != null) {
          errors.add(error);
        }
      }
    });
    
    return errors;
  }
}
