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

    return Column(
      children: [
        // Prophet Header with transparent background
        ProphetHeader(
          profet: profet,
          prophetTypeString: ProphetUtils.prophetTypeToString(selectedProphet),
        ),

        ThemeUtils.spacerLG,

        // Oracle Avatar with loading state
        if (isLoading)
          LoadingStateWidget(selectedProphet: selectedProphet)
        else
          OracleAvatar(profet: profet),

        ThemeUtils.spacerLG,

        // Question Input Field with theme styling
        Container(
          decoration: ThemeUtils.getProphetCardDecoration(selectedProphet),
          padding: ThemeUtils.paddingMD,
          child: TextFormField(
            controller: questionController,
            decoration: ThemeUtils.getProphetInputDecoration(
              selectedProphet,
              labelText: localizations.enterQuestionPlaceholder(
                prophetName.isNotEmpty ? prophetName : 'Oracle'
              ),
              prefixIcon: Icons.help_outline,
            ),
            maxLines: 3,
            validator: ValidationUtils.validateQuestion,
          ),
        ),

        ThemeUtils.spacerXL,

        // Action buttons with theme styling
        OracleActionButtons(
          selectedProphet: selectedProphet,
          onAskOracle: onAskOracle,
          onListenToOracle: onListenToOracle,
        ),

        // Error display
        if (hasError && error != null)
          ErrorDisplayWidget(errorMessage: error!),

        const Spacer(),
      ],
    );
  }
}
