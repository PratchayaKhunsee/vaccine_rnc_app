library radio_item_selector;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// The instance of an radio item.
class RadioItem<V> {
  /// The string for displaying in the label of the radio item.
  String? text;

  /// The value of the radio item.
  V? value;
  bool _selected;
  RadioItem({
    this.text,
    this.value,
    bool? selected,
  }) : this._selected = selected ?? false;
}

class _CurrentRadioItem<V> extends ChangeNotifier {
  RadioItem<V>? _current;
  RadioItem<V>? get current => _current;
  set current(RadioItem<V>? v) {
    _current = v;
    notifyListeners();
  }
}

/// The radio item selector widget.
class RadioItemSelector<V> extends StatelessWidget {
  /// List of [RadioItem].
  final List<RadioItem<V>>? items;
  final _CurrentRadioItem<V> _current;

  /// The selected [RadioItem].
  RadioItem<V>? get selectedItem => _current.current;

  RadioItemSelector({
    this.items,
    Key? key,
  })  : _current = _CurrentRadioItem(),
        super(key: key) {
    _current._current = items!.firstWhere(
      (e) => e._selected,
      orElse: () => items!.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_CurrentRadioItem>.value(
      value: _current,
      builder: (context, child) => ListView(
        children: items!
            .map<Widget>(
              (e) => Consumer<_CurrentRadioItem<V>>(
                builder: (context, selectedItem, child) {
                  return RadioListTile<RadioItem<V>>(
                    value: e,
                    groupValue: selectedItem.current,
                    onChanged: (instance) {
                      selectedItem.current = instance;
                    },
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
