library simple_textfield;

import 'package:flutter/material.dart';
import 'dart:math';

/// It can determine how the text field works.
enum SimpleTextFieldInputType {
  /// It is the default.
  text,

  /// It enables the text obscuring feature for the text field.
  password
}

class _SimpleTextFieldProperties {
  String? value;
  TextEditingController? controller;
  _SimpleTextFieldProperties({this.value});
}

/// The instance that representing a simple text field. Its value type is [String].
class SimpleTextField extends StatelessWidget {
  /// Rendering the text field to be disabled when it is true.
  final bool disabled;

  /// The text field input type.
  final SimpleTextFieldInputType type;

  /// The maximum number of the value length. If it is null, there is no limit for the range.
  final int? maxLength;

  /// The text displaying for the empty text field.
  final String? placeholder;
  final _SimpleTextFieldProperties _properties;

  /// Being triggered when user performs inputting the text field.
  final void Function(String value)? onInput;

  /// The value of the text field.
  String? get value => _properties.value;
  set value(String? value) {
    _properties.controller!.value = TextEditingValue(text: value!);
    if (maxLength is int && maxLength != null)
      _properties.value = '$value'.substring(0, max(maxLength!, 0));
  }

  SimpleTextField({
    Key? key,
    this.disabled = false,
    this.type = SimpleTextFieldInputType.text,
    this.maxLength,
    this.placeholder,
    this.onInput,
    String? value,
  })  : this._properties = _SimpleTextFieldProperties(value: value),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: _properties.value);

    _properties.controller = controller;

    TextFormField textfield = TextFormField(
      controller: controller,
      enabled: !disabled,
      maxLength: maxLength,
      obscureText: type == SimpleTextFieldInputType.password,
      decoration: InputDecoration(
        hintText: placeholder,
      ),
      onChanged: (value) {
        _properties.value = value;
        onInput!(value);
      },
    );

    return Container(
      child: Material(
        child: textfield,
      ),
    );
  }
}
