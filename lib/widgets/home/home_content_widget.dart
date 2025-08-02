import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../utils/utils.dart';
import '../../l10n/app_localizations.dart';
import 'prophet_header.dart';
import 'oracle_avatar.dart';
import 'oracle_action_buttons.dart';
import 'loading_state_widget.dart';
import 'error_display_widget.dart';

/// The main content widget for the home screen.
/// Combines all home screen elements in a clean, organized structure.
class HomeContentWidget extends StatefulWidget {
  final ProfetType selectedProphet;
  final TextEditingController questionController;
  final String prophetName;
  final bool isLoading;
  final bool hasError;
  final String? error;
  final VoidCallback onAskOracle;
  final VoidCallback onListenToOracle;

  const HomeContentWidget({
    super.key,
    required this.selectedProphet,
    required this.questionController,
    required this.prophetName,
    required this.isLoading,
    required this.hasError,
    this.error,
    required this.onAskOracle,
    required this.onListenToOracle,
  });

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget> {
  bool _isQuestionEmpty = true;

  @override
  void initState() {
    super.initState();
    _isQuestionEmpty = widget.questionController.text.trim().isEmpty;
    widget.questionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.questionController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isEmpty = widget.questionController.text.trim().isEmpty;
    if (_isQuestionEmpty != isEmpty) {
      setState(() {
        _isQuestionEmpty = isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProphet);
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400; // Detect smartphones

    return GestureDetector(
      onTap: () {
        // Remove focus from any text field when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Prophet Header with transparent background
            ProphetHeader(
              profet: profet,
              prophetTypeString: ProphetUtils.prophetTypeToString(widget.selectedProphet),
            ),

            isSmallScreen ? ThemeUtils.spacerMD : ThemeUtils.spacerLG, // Reduced spacing on mobile

            // Oracle Avatar with loading state
            if (widget.isLoading)
              LoadingStateWidget(selectedProphet: widget.selectedProphet)
            else
              OracleAvatar(profet: profet),

            isSmallScreen ? ThemeUtils.spacerMD : ThemeUtils.spacerLG, // Reduced spacing on mobile

            // Question Input Field with single container styling
            TextFormField(
              controller: widget.questionController,
              decoration: ThemeUtils.getProphetInputDecoration(
                widget.selectedProphet,
                labelText: localizations.enterQuestionPlaceholder(
                  widget.prophetName.isNotEmpty ? widget.prophetName : 'Oracle'
                ),
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: ThemeUtils.getProphetColor(widget.selectedProphet).withValues(alpha: 0.1),
              ),
              maxLines: 3,
              validator: ValidationUtils.validateQuestion,
            ),

            isSmallScreen ? ThemeUtils.spacerLG : ThemeUtils.spacerXL, // Reduced spacing on mobile

            // Action buttons with theme styling
            OracleActionButtons(
              selectedProphet: widget.selectedProphet,
              onAskOracle: widget.onAskOracle,
              onListenToOracle: widget.onListenToOracle,
              isQuestionEmpty: _isQuestionEmpty,
            ),

            // Error display
            if (widget.hasError && widget.error != null)
              ErrorDisplayWidget(errorMessage: widget.error!),

            // Bottom spacing instead of Spacer for scrollable content
            isSmallScreen ? ThemeUtils.spacerLG : ThemeUtils.spacerXL, // Reduced spacing on mobile
          ],
        ),
      ),
    );
  }
}
