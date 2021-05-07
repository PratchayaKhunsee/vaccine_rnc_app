import 'package:flutter/widgets.dart';

class _State extends State<PersistentWidget>
    with AutomaticKeepAliveClientMixin<PersistentWidget> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class PersistentWidget extends StatefulWidget {
  final Widget child;

  const PersistentWidget({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  _State createState() => _State();
}
