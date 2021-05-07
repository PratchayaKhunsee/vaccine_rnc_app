import 'package:flutter/material.dart';
import '_base.dart';

const _allowedInputType = ['text', 'password'];

class _TextEditController extends TextEditingController {
  _TextEditController(_InputState instance, {String text}) : super() {
    super.text = text;
    super.selection = TextSelection.fromPosition(
      TextPosition(
        offset: instance.widget.value.length,
      ),
    );
  }
}

Widget _createTextField(
  _InputState instance,
  BuildContext context,
) {
  return IgnorePointer(
    ignoring: instance.widget.disabled,
    child: TextFormField(
      controller: _TextEditController(
        instance,
        text: instance.widget.value,
      ),
      decoration: InputDecoration(
        hintText: instance.widget.placeholder,
        filled: true,
        fillColor:
            instance.widget.disabled ? Color(0x1f000000) : Color(0x00ffffff),
      ),
      obscureText: instance.widget._data.type == 'password',
      onChanged: (value) {
        instance.widget._data.value = value;
        instance.widget._data.onChanged?.call(value);
      },
    ),
  );
}

class _InputData {
  bool disabled = true;
  String value = '';
  String placeholder = '';
  String type = 'text';
  Function(String value) onChanged;
  Widget widget;
  TextEditingController textController;
}

class _InputState extends BaseState<Input> {
  _InputState(Input widget) : super(widget);

  @override
  Widget build(BuildContext context) {
    return _createTextField(this, context);
  }
}

/// A widget that represent input component.
class Input extends BaseWidget {
  final _InputData _data = _InputData();

  Input({
    String value = '',
    String placeholder = '',
    bool disabled = false,
    Function(String value) onChanged,
    String type = 'text',
  }) : super() {
    this._data.value = value;
    this._data.placeholder = placeholder;
    this._data.disabled = disabled;
    this._data.onChanged = onChanged;
    this._data.type =
        _allowedInputType.indexOf(type) != -1 ? type : _allowedInputType[0];
  }

  String get value => this._data.value;
  String get placeholder => this._data.placeholder;
  bool get disabled => this._data.disabled;
  Function(String value) get onChanged => this._data.onChanged;

  set placeholder(dynamic x) {
    this.updateState(() {
      this._data.placeholder = x as String;
    });
  }

  set disabled(dynamic x) {
    this.updateState(() {
      this._data.disabled = x as bool;
    });
  }

  set onChanged(void onChanged(String value)) {
    this.updateState(() {
      this._data.onChanged = onChanged;
    });
  }

  @override
  _InputState createState() {
    return _InputState(this);
  }
}
