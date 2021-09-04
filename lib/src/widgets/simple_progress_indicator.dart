library simple_progress_indicator;

import 'package:flutter/material.dart';

enum ProgressIndicatorSize {
  small,
  medium,
  large,
  extraLarge,
}

/// The simple progress indicator widget that was simply determined by
/// [ProgressIndicatorSize].
class SimpleProgressIndicator extends StatelessWidget {
  /// The size of [CircularProgressIndicator].
  final ProgressIndicatorSize? size;

  /// It must be between 0.0 and 1.0, and null(indeterminated).
  final double? value;

  SimpleProgressIndicator({
    Key? key,
    this.size,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case ProgressIndicatorSize.small:
        return SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: value,
          ),
        );
      case ProgressIndicatorSize.large:
        return SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 7,
            value: value,
          ),
        );
      case ProgressIndicatorSize.extraLarge:
        return SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            strokeWidth: 10,
            value: value,
          ),
        );
      default:
        return SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            value: value,
          ),
        );
    }
  }
}
