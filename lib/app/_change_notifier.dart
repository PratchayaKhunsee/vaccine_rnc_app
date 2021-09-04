import 'package:flutter/widgets.dart';

class BooleanNotifier extends ValueNotifier<bool> {
  BooleanNotifier([
    bool value = false,
  ]) : super(value);
}
