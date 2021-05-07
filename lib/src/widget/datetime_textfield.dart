import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class _Data {
  DateTime value;
  DateTime initialDate;
  DateTime firstDate;
  DateTime lastDate;
  void Function(DateTime value) onChange;
}

class DateTimeTextField extends StatelessWidget {
  final TextEditingController _controller;
  final _Data _data = _Data();

  DateTimeTextField({
    Key key,
    DateTime value,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
    void Function(DateTime value) onChange,
  })  : _controller = TextEditingController(),
        super(key: key) {
    _data.initialDate = initialDate;
    _data.value = value;
    _data.firstDate = firstDate;
    _data.lastDate = lastDate;
    _data.onChange = onChange;

    if (value != null) {
      _controller.text = '${value.day}/${value.month}/${value.year}';
    }
  }

  DateTime get initialDate => _data.initialDate;
  DateTime get firstDate => _data.firstDate;
  DateTime get lastDate => _data.lastDate;
  DateTime get value => _data.value;
  void Function(DateTime value) get onChange => _data.onChange;
  set initialDate(DateTime x) {
    _data.initialDate = x;
  }

  set firstDate(DateTime x) {
    _data.firstDate = x;
  }

  set lastDate(DateTime x) {
    _data.lastDate = x;
  }

  set value(DateTime x) {
    if (x == null) return;
    _data.value = x;
    _controller.text = '${x.day}/${x.month}/${x.year}';
  }

  Future<DateTime> _showDatePicker(BuildContext context) async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _data.initialDate ?? DateTime.now(),
      firstDate: _data.firstDate ?? DateTime(1970),
      lastDate: _data.lastDate ?? DateTime.now(),
    );

    return selected;
  }

  @override
  Widget build(BuildContext context) {
    TextField _textField = TextField(
      enabled: false,
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'เลือกวันที่',
      ),
    );
    return GestureDetector(
      onTap: () async {
        DateTime value = await _showDatePicker(context);
        if (value != null) {
          _data.value = value;
          _controller.text = '${value.day}/${value.month}/${value.year}';
          _data.onChange.call(value);
        }
      },
      child: _textField,
    );
  }
}
