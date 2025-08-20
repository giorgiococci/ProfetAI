import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../widgets/home/home_content_widget.dart';
import '../utils/theme_utils.dart';
import '../utils/prophet_utils.dart';

/// Dedicated screen for viewing/continuing a specific conversation
class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final ProfetType prophetType;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.prophetType,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _prophetName = '';

  @override
  void initState() {
    super.initState();
    _loadProphetName();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadProphetName() async {
    try {
      final name = await ProphetUtils.getProphetName(context, widget.prophetType);
      if (mounted) {
        setState(() {
          _prophetName = name;
        });
      }
    } catch (e) {
      // Handle error silently, use default empty name
    }
  }

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.prophetType);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: profet.backgroundImagePath != null
              ? DecorationImage(
                  image: AssetImage(profet.backgroundImagePath!),
                  fit: BoxFit.cover,
                  opacity: 0.7,
                )
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: ThemeUtils.paddingLG,
            child: HomeContentWidget(
              selectedProphet: widget.prophetType,
              questionController: _questionController,
              prophetName: _prophetName,
              isLoading: false,
              hasError: false,
              onAskOracle: _handleAskOracle,
              onListenToOracle: _handleListenToOracle,
              isConversationStarted: true, // Always in conversation mode
              autoLoadConversationId: widget.conversationId, // Auto-load this conversation
            ),
          ),
        ),
      ),
    );
  }

  void _handleAskOracle() {
    // The HomeContentWidget will handle sending the message
  }

  void _handleListenToOracle() {
    // The HomeContentWidget will handle listening
  }
}
