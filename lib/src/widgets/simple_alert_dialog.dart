import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The namespace class that provides the alert dialog usage.
class SimpleAlertDialog {
  /// Display the alert dialog.
  ///
  /// The asynchronous function should be released when the dialog is closed.
  static Future<void> show(
    BuildContext context, {
    String? title,
    Widget? body,
    bool hasCloseButton = false,
    String closeButtonText = 'Close',
    List<Widget>? actions,
  }) async {
    Widget createDialog() {
      TextButton createCloseButton() => TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(closeButtonText),
          );

      List<Widget> _actions = [];
      if (actions != null) _actions.addAll(actions);
      if (hasCloseButton) _actions.add(createCloseButton());

      return AlertDialog(
        title: title != null ? Text(title) : null,
        content: body,
        actions: actions != null || hasCloseButton ? _actions : null,
      );
    }

    await showDialog(
      context: context,
      builder: (context) => createDialog(),
    );
  }
}
