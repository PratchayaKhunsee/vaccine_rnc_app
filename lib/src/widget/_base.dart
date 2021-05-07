import 'package:flutter/widgets.dart';

class _Base {
  BaseState instance;
}

abstract class BaseState<T extends BaseWidget> extends State<T> {
  BaseState(T widget) : super() {
    widget._state.instance = this;
  }

  void updateState(void callback()) {
    this.setState(callback);
  }
}

abstract class BaseWidget extends StatefulWidget {
  final _Base _state = _Base();

  void updateState(void callback()) {
    this._state.instance?.updateState(callback);
  }
}
