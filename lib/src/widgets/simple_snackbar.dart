import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The namespace of the [SnackBar] usage.
class SimpleSnackbar {
  static SnackBar _createSnackBar(String message) => SnackBar(
        content: Text(message),
      );

  /// Manipulate [ScaffoldMessengerState.showSnackBar] and [SnackBar]
  /// with a message inside of it depending on [context]'s build context or
  /// [scaffoldMessengerStateKey]'s global key.
  static Future<void> push({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
    required String message,
  }) async {
    SnackBar snackbar = _createSnackBar(message);
    if (scaffoldMessengerStateKey != null &&
        scaffoldMessengerStateKey.currentState != null)
      await scaffoldMessengerStateKey.currentState!
          .showSnackBar(snackbar)
          .closed;
    else if (context != null) {
      await ScaffoldMessenger.of(context).showSnackBar(snackbar).closed;
    }
  }
}
