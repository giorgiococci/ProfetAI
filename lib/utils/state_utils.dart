import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';

/// State management utilities for managing widget states and form states
/// Provides helpers for common state management patterns
class StateUtils {
  
  /// Manages form state with validation
  static bool validateAndSubmitForm(
    GlobalKey<FormState> formKey,
    VoidCallback onValid, {
    VoidCallback? onInvalid,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      onValid();
      return true;
    } else {
      onInvalid?.call();
      return false;
    }
  }

  /// Resets form state
  static void resetForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.reset();
  }

  /// Saves form state
  static void saveForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.save();
  }

  /// Checks if context is still valid
  static bool isContextValid(BuildContext? context) {
    return context != null && context.mounted;
  }

  /// Safe navigation that checks context validity
  static void safeExecute(BuildContext? context, VoidCallback? action) {
    if (isContextValid(context) && action != null) {
      action();
    }
  }

  /// Debounces function calls to prevent excessive executions
  static void debounce(
    String identifier,
    VoidCallback fn, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimers[identifier]?.cancel();
    _debounceTimers[identifier] = Timer(delay, fn);
  }

  static final Map<String, Timer> _debounceTimers = {};

  /// Clears all debounce timers
  static void clearAllDebounce() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }
}

/// Mixin for managing loading states in StatefulWidgets
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        if (loading) _error = null; // Clear error when loading starts
      });
    }
  }

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _error = error;
        _isLoading = false; // Stop loading when error occurs
      });
    }
  }

  void clearError() {
    if (mounted) {
      setState(() {
        _error = null;
      });
    }
  }

  Future<void> executeWithLoading(Future<void> Function() operation) async {
    setLoading(true);
    try {
      await operation();
      setLoading(false);
    } catch (e) {
      setError(e.toString());
    }
  }
}

/// Mixin for managing form states in StatefulWidgets
mixin FormStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  Map<String, dynamic> _formData = {};

  bool get isFormValid => _isFormValid;
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);

  void updateFormField(String key, dynamic value) {
    if (mounted) {
      setState(() {
        _formData[key] = value;
        _validateForm();
      });
    }
  }

  void _validateForm() {
    _isFormValid = formKey.currentState?.validate() ?? false;
  }

  bool submitForm(VoidCallback onValid) {
    return StateUtils.validateAndSubmitForm(
      formKey,
      onValid,
      onInvalid: () {
        if (mounted) {
          setState(() {
            _isFormValid = false;
          });
        }
      },
    );
  }

  void resetForm() {
    if (mounted) {
      setState(() {
        _formData.clear();
        _isFormValid = false;
      });
    }
    StateUtils.resetForm(formKey);
  }

  T? getFormValue<T>(String key) {
    return _formData[key] as T?;
  }
}

/// State holder for prophet selection
class ProphetSelectionState extends ChangeNotifier {
  ProfetType _selectedProphet = ProfetType.mistico;
  bool _isLoading = false;
  String? _error;

  ProfetType get selectedProphet => _selectedProphet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  void selectProphet(ProfetType prophet) {
    _selectedProphet = prophet;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// State holder for vision/question interactions
class VisionState extends ChangeNotifier {
  String _currentQuestion = '';
  String _currentVision = '';
  bool _isAIEnabled = false;
  bool _isLoading = false;
  String? _error;

  String get currentQuestion => _currentQuestion;
  String get currentVision => _currentVision;
  bool get isAIEnabled => _isAIEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasQuestion => _currentQuestion.isNotEmpty;
  bool get hasVision => _currentVision.isNotEmpty;

  void setQuestion(String question) {
    _currentQuestion = question;
    _error = null;
    notifyListeners();
  }

  void setVision(String vision, {bool aiEnabled = false}) {
    _currentVision = vision;
    _isAIEnabled = aiEnabled;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearAll() {
    _currentQuestion = '';
    _currentVision = '';
    _isAIEnabled = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
