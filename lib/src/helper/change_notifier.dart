import 'package:flutter/widgets.dart';

class FixedTypeNotifier<T> extends ChangeNotifier {
  T _value;
  FixedTypeNotifier({
    T value,
  })  : _value = value,
        super();
  T get value => _value;
  set value(T x) {
    if (x == _value) return;

    _value = x;
    notifyListeners();
  }
}

class BooleanNotifier extends FixedTypeNotifier<bool> {
  BooleanNotifier({
    bool value,
  }) : super(value: value ?? false);
}

class IntNotifier extends FixedTypeNotifier<int> {
  IntNotifier({
    int value,
  }) : super(value: value ?? 0);
}

class PlainStringNotifier extends FixedTypeNotifier<String> {
  PlainStringNotifier({
    String value,
  }) : super(value: value);
}

class MapNotifier<K, V> extends FixedTypeNotifier<Map<K, V>> {
  MapNotifier({
    Map<K, V> value,
  }) : super(value: value);
}

class ListNotifier<T> extends FixedTypeNotifier<List<T>> {
  ListNotifier({
    List<T> value,
  }) : super(value: value);
}
