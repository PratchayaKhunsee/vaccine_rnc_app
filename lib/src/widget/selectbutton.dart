import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class _Data {
  dynamic value;
  List<SelectOption> options;
  Function(dynamic value) onChangedd;
}

class _State {
  _SButtonState state;
}

class _SButtonState extends State<SelectButton> {
  _SButtonState(SelectButton widget) : super() {
    widget._state.state = this;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: this.widget._data.value ?? this.widget._data.options[0]?.value,
      items: (this.widget._data.options.map(
            (e) => DropdownMenuItem(
              child: Text(e.text ?? ''),
              value: e.value,
            ),
          )).toList(),
      onChanged: (value) {
        setState(() {
          this.widget._data.value = value;
        });
        this.widget._data.onChangedd(value);
      },
    );
  }
}

class SelectOption {
  dynamic value;
  String text;
  SelectOption({this.value, this.text});
}

class SelectButton extends StatefulWidget {
  final _Data _data = _Data();
  final _State _state = _State();

  SelectButton(
    List<SelectOption> options, {
    Function(dynamic value) onChangedd,
  }) : super() {
    this._data.options = options;
    this._data.onChangedd = onChangedd;
  }

  @override
  _SButtonState createState() {
    return _SButtonState(this);
  }

  dynamic get value => this._data.value;
}
