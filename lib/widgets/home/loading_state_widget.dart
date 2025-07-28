import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../utils/utils.dart';

/// A loading state widget that displays a circular progress indicator
/// with prophet-specific theming and a loading message.
class LoadingStateWidget extends StatelessWidget {
  final ProfetType selectedProphet;
  final String? loadingMessage;

  const LoadingStateWidget({
    super.key,
    required this.selectedProphet,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(
          color: ThemeUtils.getProphetColor(selectedProphet),
        ),
        ThemeUtils.spacerSM,
        Text(
          loadingMessage ?? 'Loading...',
          style: ThemeUtils.getProphetTextStyle(selectedProphet),
        ),
      ],
    );
  }
}
