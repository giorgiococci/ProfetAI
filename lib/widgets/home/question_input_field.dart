import 'package:flutter/material.dart';
import '../../models/profet.dart';

/// A themed text input field for asking questions to the oracle.
/// Includes prophet-specific styling and responsive behavior.
class QuestionInputField extends StatelessWidget {
  final TextEditingController controller;
  final Profet profet;
  final String hintText;
  final int maxLines;
  final int minLines;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;

  const QuestionInputField({
    super.key,
    required this.controller,
    required this.profet,
    required this.hintText,
    this.maxLines = 3,
    this.minLines = 1,
    this.textStyle,
    this.hintStyle,
    this.padding,
    this.contentPadding,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: profet.primaryColor.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: textStyle ??
            TextStyle(
              color: Colors.grey[100],
              fontSize: 16,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                color: Colors.grey[400],
              ),
          border: InputBorder.none,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
        ),
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// A more advanced question input with validation and state management
class AdvancedQuestionInput extends StatefulWidget {
  final TextEditingController controller;
  final Profet profet;
  final String hintText;
  final String? Function(String?)? validator;
  final Function(String)? onValidSubmission;
  final int maxLines;
  final int minLines;
  final bool showCharacterCount;
  final int? maxLength;

  const AdvancedQuestionInput({
    super.key,
    required this.controller,
    required this.profet,
    required this.hintText,
    this.validator,
    this.onValidSubmission,
    this.maxLines = 3,
    this.minLines = 1,
    this.showCharacterCount = false,
    this.maxLength,
  });

  @override
  State<AdvancedQuestionInput> createState() => _AdvancedQuestionInputState();
}

class _AdvancedQuestionInputState extends State<AdvancedQuestionInput> {
  String? _errorText;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
        _isValid = error == null;
      });
    }
  }

  void _handleSubmission(String value) {
    if (_isValid && widget.onValidSubmission != null) {
      widget.onValidSubmission!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _isValid
                  ? widget.profet.primaryColor.withValues(alpha: 0.5)
                  : Colors.red.withValues(alpha: 0.7),
              width: _isValid ? 1 : 2,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            style: TextStyle(
              color: Colors.grey[100],
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              counterText: widget.showCharacterCount ? null : '',
            ),
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            onSubmitted: _handleSubmission,
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 12,
              ),
            ),
          ),
        ],
        if (widget.showCharacterCount && widget.maxLength != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.controller.text.length}/${widget.maxLength}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ],
    );
  }
}

/// A floating action button style input that expands when tapped
class FloatingQuestionInput extends StatefulWidget {
  final TextEditingController controller;
  final Profet profet;
  final String hintText;
  final Function(String)? onSubmitted;

  const FloatingQuestionInput({
    super.key,
    required this.controller,
    required this.profet,
    required this.hintText,
    this.onSubmitted,
  });

  @override
  State<FloatingQuestionInput> createState() => _FloatingQuestionInputState();
}

class _FloatingQuestionInputState extends State<FloatingQuestionInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          height: 50 + (100 * _expandAnimation.value),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.profet.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          child: _isExpanded
              ? TextField(
                  controller: widget.controller,
                  style: TextStyle(color: Colors.grey[100], fontSize: 16),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: widget.profet.primaryColor,
                      ),
                      onPressed: () {
                        if (widget.controller.text.trim().isNotEmpty) {
                          widget.onSubmitted?.call(widget.controller.text.trim());
                          _toggleExpanded();
                        }
                      },
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  autofocus: true,
                )
              : GestureDetector(
                  onTap: _toggleExpanded,
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: widget.profet.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.hintText,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
