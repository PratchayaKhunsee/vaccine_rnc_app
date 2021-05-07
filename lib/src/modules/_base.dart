import 'package:flutter/widgets.dart';

class _BaseState {
  State state;
}

class _BaseData<D extends Data> {
  D data;
}

class Data {}

abstract class BaseStatefulWidget<T extends BaseWidget> extends StatefulWidget {
  final T baseWidget;

  BaseStatefulWidget(T parent)
      : this.baseWidget = parent,
        super();
}

abstract class BaseWidget<T extends State, D extends Data>
    extends StatelessWidget {
  final _BaseState _state = _BaseState();
  final _BaseData<D> _data = _BaseData();

  BaseWidget(D data) : super() {
    this._data.data = data;
  }

  T get state => this._state.state;
  D get data => this._data.data;
  set state(T state) {
    this._state.state = state;
  }
}

class _BaseModuleStateProvider {
  BaseModuleState instance;
}

/// The internal state for [BaseModule]; inherits from [State] class.
abstract class BaseModuleState<T extends BaseModule> extends State<T> {
  BaseModuleState(T module) : super() {
    module._state.instance = this;
  }

  /// Trigger the internal [State.setState] method.
  ///
  /// The purpose for [State.setState] is to be used internally,
  /// This method can be used externally for handling the [State.setState]
  /// method with ease.
  void updateState(void callback()) {
    this.setState(callback);
  }
}

/// The module that actually is a widget and it inherits [StatefulWidget].
abstract class BaseModule extends StatefulWidget {
  final _BaseModuleStateProvider _state = _BaseModuleStateProvider();

  /// Externally trigger the internal [State.setState].
  void updateState(void callback()) {
    // debugPrint(this._state.instance.toString());
    this._state.instance.updateState(callback);
  }
}

/// A widget that represent the module of the whole app.
/// * Making code more semantic
abstract class Module extends StatelessWidget {
  /// Instead using this method to create widget tree.
  Widget createWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: this.createWidget(context),
      onTap: () {
        FocusScopeNode focus = FocusScope.of(context);
        if (!focus.hasPrimaryFocus) {
          focus.unfocus();
        }
      },
    );
  }
}
