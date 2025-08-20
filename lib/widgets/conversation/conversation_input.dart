import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';

/// Input widget for conversation messages
/// Provides a text field with send button and prophet-themed styling
class ConversationInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isLoading;
  final ProfetType prophetType;
  final String? hintText;
  final int maxLines;
  final bool enabled;

  const ConversationInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    required this.prophetType,
    this.hintText,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<ConversationInput> createState() => _ConversationInputState();
}

class _ConversationInputState extends State<ConversationInput>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulsing animation when loading
    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConversationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation based on loading state
    if (widget.isLoading && !oldWidget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading && widget.enabled) {
      widget.onSend(text);
    }
  }

  Color _getProphetColor() {
    final prophet = ProfetManager.getProfet(widget.prophetType);
    return prophet.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildTextField(),
            ),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: widget.isLoading 
              ? _getProphetColor().withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled && !widget.isLoading,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? _getDefaultHintText(),
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          suffixIcon: widget.controller.text.isNotEmpty && !widget.isLoading
              ? IconButton(
                  onPressed: () {
                    widget.controller.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                )
              : null,
        ),
        maxLines: widget.maxLines,
        textInputAction: TextInputAction.send,
        onSubmitted: widget.enabled && !widget.isLoading ? (_) => _handleSend() : null,
        onChanged: (_) => setState(() {}), // Rebuild to show/hide clear button
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading ? _pulseAnimation.value : 1.0,
          child: IconButton(
            onPressed: widget.enabled && !widget.isLoading ? _handleSend : null,
            icon: widget.isLoading
                ? _buildLoadingIndicator()
                : _buildSendIcon(),
            style: IconButton.styleFrom(
              backgroundColor: _getProphetColor().withValues(alpha: 0.3),
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: widget.isLoading ? 'Sending...' : 'Send Message',
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_getProphetColor()),
      ),
    );
  }

  Widget _buildSendIcon() {
    return Icon(
      Icons.send,
      color: widget.enabled 
          ? Colors.white
          : Colors.white.withValues(alpha: 0.5),
      size: 20,
    );
  }

  String _getDefaultHintText() {
    switch (widget.prophetType) {
      case ProfetType.mistico:
        return 'Share your mystical thoughts...';
      case ProfetType.caotico:
        return 'Embrace the chaos...';
      case ProfetType.cinico:
        return 'Ask your cynical question...';
      case ProfetType.roaster:
        return 'Ready to get roasted?...';
    }
  }
}
