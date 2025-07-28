import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../utils/utils.dart';
import '../../l10n/app_localizations.dart';

/// A widget that displays the main action buttons for the oracle interface.
/// Includes "Ask the Oracle" and "Listen to Oracle" buttons with prophet theming.
class OracleActionButtons extends StatelessWidget {
  final ProfetType selectedProphet;
  final VoidCallback onAskOracle;
  final VoidCallback onListenToOracle;

  const OracleActionButtons({
    super.key,
    required this.selectedProphet,
    required this.onAskOracle,
    required this.onListenToOracle,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Ask Oracle Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ThemeUtils.getProphetButtonStyle(selectedProphet),
            onPressed: onAskOracle,
            icon: const Icon(Icons.help_outline),
            label: Text(
              localizations.askTheOracle,
              style: ThemeUtils.buttonTextStyle,
            ),
          ),
        ),

        ThemeUtils.spacerMD,

        // Listen to Oracle Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: ThemeUtils.getSecondaryButtonStyle(
              borderColor: ThemeUtils.getProphetSecondaryColor(selectedProphet),
            ),
            onPressed: onListenToOracle,
            icon: Icon(
              Icons.hearing,
              color: ThemeUtils.getProphetSecondaryColor(selectedProphet),
            ),
            label: Text(
              localizations.listenToOracle,
              style: ThemeUtils.getProphetTextStyle(selectedProphet).copyWith(
                color: ThemeUtils.getProphetSecondaryColor(selectedProphet),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
