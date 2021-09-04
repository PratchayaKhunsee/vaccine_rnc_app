library simple_dropdown_button;

import 'package:flutter/material.dart';

class _SimpleDropdownButtonValue<V> {
  SimpleDropdownButtonItem<V>? selected;
}

class _SimpleDropdownButtonState<V> extends State<SimpleDropdownButton<V>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<SimpleDropdownButtonItem<V>>(
      value: this.widget._current.selected,
      items: this
          .widget
          .items!
          .map<DropdownMenuItem<SimpleDropdownButtonItem<V>>>(
              (e) => DropdownMenuItem<SimpleDropdownButtonItem<V>>(
                    child: Text(e.text ?? ''),
                    value: e,
                  ))
          .toList(),
      onChanged: this.widget.disabled
          ? null
          : (value) {
              setState(() {
                this.widget._current.selected = value;
              });
              this.widget.onChanged?.call(value);
            },
    );
  }
}

/// The item instance for [SimpleDropdownButton].
class SimpleDropdownButtonItem<V> {
  /// The instance value.
  V? value;

  /// The diplaying text.
  String? text;
  bool _selected;
  SimpleDropdownButtonItem({
    this.text,
    this.value,
    bool selected = false,
  }) : this._selected = selected;
}

/// The simple dropdown button widget instance.
class SimpleDropdownButton<V> extends StatefulWidget {
  /// The list of [SimpleDropdownButtonItem].
  final List<SimpleDropdownButtonItem<V>>? items;
  final _SimpleDropdownButtonValue<V> _current;

  /// Being triggered when the [SimpleDropdownButton.selectedItem] is changed.
  final void Function(SimpleDropdownButtonItem<V>? selected)? onChanged;

  /// The dropdown button will be disabled if it is true.
  final bool disabled;

  /// The selected [SimpleDropdownButtonItem].
  SimpleDropdownButtonItem<V>? get selectedItem => _current.selected;

  SimpleDropdownButton({
    Key? key,
    this.items,
    this.onChanged,
    this.disabled = false,
  })  : this._current = _SimpleDropdownButtonValue(),
        super(key: key) {
    SimpleDropdownButtonItem<V> selected = items!.firstWhere(
      (e) => e._selected,
      orElse: () => items!.first,
    );
    _current.selected = selected;
  }

  @override
  _SimpleDropdownButtonState<V> createState() =>
      _SimpleDropdownButtonState<V>();
}
