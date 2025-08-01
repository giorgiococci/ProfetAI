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
class HomeContentWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(selectedProphet);
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400; // Detect smartphones

    return SingleChildScrollView(
      child: Column(
        children: [
          // Prophet Header with transparent background
          ProphetHeader(
            profet: profet,
            prophetTypeString: ProphetUtils.prophetTypeToString(selectedProphet),
          ),

          isSmallScreen ? ThemeUtils.spacerMD : ThemeUtils.spacerLG, // Reduced spacing on mobile

          // Oracle Avatar with loading state
          if (isLoading)
            LoadingStateWidget(selectedProphet: selectedProphet)
          else
            OracleAvatar(profet: profet),

          isSmallScreen ? ThemeUtils.spacerMD : ThemeUtils.spacerLG, // Reduced spacing on mobile

          // Question Input Field with single container styling
          TextFormField(
            controller: questionController,
            decoration: ThemeUtils.getProphetInputDecoration(
              selectedProphet,
              labelText: localizations.enterQuestionPlaceholder(
                prophetName.isNotEmpty ? prophetName : 'Oracle'
              ),
            ).copyWith(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              fillColor: ThemeUtils.getProphetColor(selectedProphet).withValues(alpha: 0.1),
            ),
            maxLines: 3,
            validator: ValidationUtils.validateQuestion,
          ),

          isSmallScreen ? ThemeUtils.spacerLG : ThemeUtils.spacerXL, // Reduced spacing on mobile

          // Action buttons with theme styling
          OracleActionButtons(
            selectedProphet: selectedProphet,
            onAskOracle: onAskOracle,
            onListenToOracle: onListenToOracle,
          ),

          // Error display
          if (hasError && error != null)
            ErrorDisplayWidget(errorMessage: error!),

          // Bottom spacing instead of Spacer for scrollable content
          isSmallScreen ? ThemeUtils.spacerLG : ThemeUtils.spacerXL, // Reduced spacing on mobile
        ],
      ),
    );
  }
}
