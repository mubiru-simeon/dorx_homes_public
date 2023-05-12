import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Container for the feedback of the user.
class UserFeedback {
  static const DIRECTORY = "feedback";

  static const SENDER = "sender";
  static const CATEGORY = "category";
  static const APPVERSION = "appVersion";
  static const TEXT = "text";
  static const ATTACHEDDATA = "attachedData";
  static const DATE = "date";
  static const ADDITIONALINFO = "additionalInfo";
  static const PENDING = "pending";
  static const IMAGES = "images";

  static const REPORT = "report";
  static const BUG = "bug";
  static const FEATURE = "feature";
  static const LIKES = "likes";
  static const DISLIKES = "dislikes";

  /// Creates an [UserFeedback].
  /// Typically never used by a user of this library.
  UserFeedback({
    @required this.text,
    @required this.screenshot,
    this.extra,
  });

  /// The user's written feedback
  final String text;

  /// A raw png encoded screenshot of the app. Probably annotated with helpful
  /// drawings by the user.
  final Uint8List screenshot;

  /// This can contain additional information. By default this is always empty.
  /// When using a custom [BetterFeedback.feedbackBuilder] this can be used
  /// to supply additional information.
  final Map<String, dynamic> extra;
}
