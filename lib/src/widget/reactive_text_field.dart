import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _DataNotifier extends ChangeNotifier {
  String placeholder;
  bool disabled = false;
  void Function(String value) onChange;
  void Function(String value) onSubmitted;
  void Function() onEditingComplete;

  void notify(void Function(_DataNotifier thisArg) callback) {
    callback(this);
  }
}

class ReactiveTextField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _DataNotifier _data = _DataNotifier();
  final void Function(String value) onChange;
  final void Function(String value) onSubmitted;
  final void Function() onEditingComplete;
  final List<TextInputFormatter> inputFormatters;

  ReactiveTextField({
    Key key,
    String initialValue,
    String placeholder,
    bool disabled = false,
    this.onChange,
    this.onSubmitted,
    this.onEditingComplete,
    this.inputFormatters,
  }) : super(key: key) {
    _controller.text = initialValue;
    _controller.selection = TextSelection.fromPosition(TextPosition(
      offset: initialValue?.length ?? 0,
    ));
    _data.placeholder = placeholder;
    _data.disabled = disabled == true;
  }

  set disabled(bool x) {
    _data.notify((thisArg) {
      thisArg.disabled = x;
    });
  }

  set placeholder(String x) {
    _data.notify((thisArg) {
      thisArg.placeholder = x;
    });
  }

  set value(dynamic x) {
    _controller.text = '$x';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _data,
      builder: (context, child) => Consumer<_DataNotifier>(
        builder: (context, value, child) {
          TextField textField = TextField(
            inputFormatters: inputFormatters,
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_data.disabled,
            decoration: InputDecoration(
              hintText: value.placeholder,
            ),
            onChanged: onChange,
            onSubmitted: onSubmitted,
            onEditingComplete: onEditingComplete,
          );

          if (value.disabled) {
            _focusNode.unfocus();
          }

          return textField;
        },
      ),
    );
  }

  static FocusNode getFocusNode(ReactiveTextField textField) =>
      textField._focusNode;
}
