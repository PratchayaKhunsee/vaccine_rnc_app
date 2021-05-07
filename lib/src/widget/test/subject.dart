import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
// import '../reactive_text_field.dart';

class TestSubject extends StatelessWidget {
  final Container _container = Container(
    width: 100,
    height: 100,
    color: Color(0x2f0000ff),
    key: GlobalKey(),
  );
  final Overlay _overlay = Overlay(
    key: GlobalKey(),
  );

  GlobalKey get _containerKey => _container.key as GlobalKey;
  GlobalKey get _overlayKey => _overlay.key as GlobalKey;

  void _showOverlay(BuildContext context) async {
    Size size = _containerKey.currentContext.size;

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        right: 0,
        child: Container(
          color: Color(0x2fff0000),
          width: size.width,
          height: size.height,
        ),
      ),
    );

    OverlayState overlayState = Overlay.of(_overlayKey.currentContext);

    overlayState?.insert(overlayEntry);

    await Future.delayed(Duration(seconds: 5));

    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOverlay(context);
      },
      child: Stack(
        children: [
          _container,
          _overlay,
        ],
      ),
    );
    // return _container;
  }
}

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
      _controller.text = '${value.day}/${value.month}/${value.year + 543}';
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
    _controller.text = '${x.day}/${x.month}/${x.year + 543}';
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
    );
    return GestureDetector(
      onTap: () async {
        // debugPrint('Select by datepicker.');
        DateTime value = await _showDatePicker(context);
        if (value != null) {
          _data.value = value;
          _controller.text = '${value.day}/${value.month}/${value.year + 543}';
        }
      },
      child: _textField,
    );
  }
}
