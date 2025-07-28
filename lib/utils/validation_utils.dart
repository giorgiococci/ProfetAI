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

  // Additional validators for enhanced form validation

  /// Enhanced password validation with configurable requirements
  static String? validatePasswordStrength(String? password, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = false,
  }) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireNumbers && !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChars && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates that passwords match
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates phone number format
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validates numeric range
  static String? validateRange(String? value, double min, double max, [String? fieldName]) {
    final numberValidation = validateNumeric(value, fieldName: fieldName ?? 'Field');
    if (numberValidation != null) return numberValidation;

    final number = double.parse(value!);
    if (number < min || number > max) {
      return '${fieldName ?? 'Field'} must be between $min and $max';
    }
    return null;
  }

  /// Validates date format
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
  }

  /// Validates exact length
  static String? validateExactLength(String? value, int exactLength, [String? fieldName]) {
    if (value == null || value.length != exactLength) {
      return '${fieldName ?? 'Field'} must be exactly $exactLength characters long';
    }
    return null;
  }

  /// Custom pattern validation
  static String? validatePattern(String? value, String pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }
    
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  /// Combines multiple validators
  static String? combineValidators(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Creates optional validator (allows empty values)
  static String? Function(String?) makeOptional(String? Function(String?) validator) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Allow empty
      }
      return validator(value);
    };
  }

  /// Validates name input (for profiles, etc.)
  static String? validateName(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }
    
    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters long';
    }
    
    if (value.trim().length > 50) {
      return '${fieldName ?? 'Name'} must be no more than 50 characters long';
    }
    
    // Allow only letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return '${fieldName ?? 'Name'} can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates age input
  static String? validateAge(String? value) {
    final numberValidation = validateInteger(value, fieldName: 'Age');
    if (numberValidation != null) return numberValidation;

    final age = int.parse(value!);
    if (age < 1 || age > 150) {
      return 'Age must be between 1 and 150';
    }
    return null;
  }

  /// Enhanced username validation
  static String? validateUsernameEnhanced(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.length > 20) {
      return 'Username must be no more than 20 characters long';
    }
    
    // Allow letters, numbers, underscore, and hyphen
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, underscore, and hyphen';
    }
    
    // Must start with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
      return 'Username must start with a letter';
    }
    
    return null;
  }

  /// Credit card validation using Luhn algorithm
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }

    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'Credit card number must contain only digits';
    }

    // Check length (most cards are 13-19 digits)
    if (cleanValue.length < 13 || cleanValue.length > 19) {
      return 'Credit card number must be 13-19 digits long';
    }

    // Luhn algorithm check
    if (!_luhnCheck(cleanValue)) {
      return 'Please enter a valid credit card number';
    }

    return null;
  }

  /// Luhn algorithm implementation for credit card validation
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
}
