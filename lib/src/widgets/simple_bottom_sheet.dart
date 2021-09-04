import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The namespace class that provides the expected bottom sheet usage.
class SimpleBottomSheet {
  /// Display a modal bottom sheet on the top of app page.
  ///
  /// This asynchronous function should be released when the modal bottom sheet is closed.
  static Future<void> showModal({
    required BuildContext context,
    required Widget builder(BuildContext context),
    double? maxWidth,
    double? maxHeight,
    bool draggable = true,
  }) async {
    Widget createModalBottomSheet(BuildContext context) {
      Size size = MediaQuery.of(context).size;
      double w = min<double>(
        size.width,
        maxWidth is double ? maxWidth : double.infinity,
      );
      double h = min<double>(
        size.height,
        maxHeight is double ? maxHeight : double.infinity,
      );

      return ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Container(
                    width: w,
                    height: h,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    color: Colors.white,
                    child: Builder(
                      builder: builder,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: draggable,
      builder: (context) => createModalBottomSheet(context),
    );
  }
}
