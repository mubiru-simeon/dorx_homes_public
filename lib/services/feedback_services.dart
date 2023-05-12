import 'package:flutter/material.dart';
import '../widgets/feedback_options_bottom_sheet.dart';
import 'services.dart';

class FeedbackServices {
  startFeedingBackward(
    BuildContext context, {
    String additionalInfo,
  }) {
    UIServices().showDatSheet(
      FeedbackOptionsBottomSheet(
        additionalInfo: additionalInfo,
      ),
      true,
      context,
    );
  }
}
