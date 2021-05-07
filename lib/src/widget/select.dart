import 'package:flutter/material.dart';
import '_base.dart';

class _SelectData {
  List<Map<String, dynamic>> options = [];
  dynamic value;
  Function(dynamic value) onChanged;
  bool disabled = false;
}

class _SelectState extends BaseState<Select> {
  _SelectState(Select widget) : super(widget);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> options = this
        .widget
        ._data
        .options
        .map((e) => DropdownMenuItem(
              child: Text(e['text'] ?? ''),
              value: e['value'] ?? e['text'] ?? '',
            ))
        .toList();

    DropdownButton select = DropdownButton(
      items: options,
      onChanged: (value) {
        this.setState(() {
          this.widget._data.value = value;
        });

        this.widget._data.onChanged?.call(value);
      },
      value: this.widget._data.value ?? options[0]?.value,
      underline: Container(),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(10, 2.5, 0, 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color:
            this.widget._data.disabled ? Color(0x1f000000) : Color(0x00ffffff),
      ),
      child: IgnorePointer(
        child: select,
        ignoring: this.widget._data.disabled,
      ),
    );
  }
}

/// A widget that represents a selectable field.
class Select extends BaseWidget {
  final _SelectData _data = _SelectData();

  Select(
    List<Map<String, dynamic>> options, {
    dynamic value,
    void onChanged(dynamic value),
    bool disabled = false,
  }) : super() {
    this._data.options = options;
    this._data.onChanged = onChanged;
    this._data.value = value;
    this._data.disabled = disabled;
  }

  dynamic get value => this._data.value;
  bool get disabled => this._data.disabled;
  Function(dynamic value) get onChanged => this._data.onChanged;
  set value(dynamic x) {
    this._data.value = x;
  }

  set disabled(bool x) {
    this._data.disabled = x;
  }

  set onChanged(void x(dynamic value)) {
    this._data.onChanged = x;
  }

  @override
  _SelectState createState() {
    return _SelectState(this);
  }
}
