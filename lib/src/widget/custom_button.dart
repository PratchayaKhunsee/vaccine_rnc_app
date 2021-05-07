import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import '_base.dart';

class _Default {
  static Gradient gradient = const LinearGradient(
    colors: [
      Color(0xff00cfff),
      Color(0xff0086ff),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static Gradient disabledGradient = const LinearGradient(
    colors: [
      Color(0xffdfdfdf),
      Color(0xffafafaf),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static EdgeInsetsGeometry padding = const EdgeInsets.all(8);
  static MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
}

// class _Shared {
//   Function() onPressed;
//   Function() onLongPress;
//   Widget child;
//   EdgeInsetsGeometry padding;
//   Gradient gradient;
//   Gradient disabledGradient;
//   bool isExpanded;
//   BorderRadiusGeometry borderRadius;
//   List<BoxShadow> boxShadow;
//   MainAxisAlignment mainAxisAlignment;
// }

// class _State extends BaseState<CustomButton> {
//   _State(CustomButton widget) : super(widget);

//   _Shared get _s => this.widget?._shared;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: _s.onPressed != null
//             ? (_s.gradient ?? _Default.gradient)
//             : (_s.disabledGradient ?? _Default.disabledGradient),
//         borderRadius: _s.borderRadius,
//         boxShadow: _s.boxShadow,
//       ),
//       child: TextButton(
//         padding: EdgeInsets.zero,
//         child: Container(
//           padding: _s.padding ?? _Default.padding,
//           constraints: BoxConstraints(
//             minWidth: _s.isExpanded == true ? double.infinity : 0,
//           ),
//           child: Row(
//             mainAxisAlignment:
//                 _s.mainAxisAlignment ?? _Default.mainAxisAlignment,
//             children: [
//               DefaultTextStyle(
//                 style: TextStyle(
//                   color: this.widget._shared.onPressed != null
//                       ? Color(0xffffffff)
//                       : null,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//                 child: this.widget._shared.child,
//               ),
//             ],
//           ),
//         ),
//         onPressed: this.widget._shared.onPressed,
//         onLongPress: this.widget._shared.onLongPress,
//       ),
//     );
//   }
// }

// class CustomButton extends BaseWidget {
//   final _Shared _shared = _Shared();
//   CustomButton({
//     Widget child,
//     void onPressed(),
//     void onLongPress(),
//     Gradient gradient,
//     EdgeInsetsGeometry padding,
//     BorderRadiusGeometry borderRadius,
//     bool isExpanded,
//     List<BoxShadow> boxShadow,
//     MainAxisAlignment mainAxisAlignment,
//   }) : super() {
//     _shared.child = child;
//     _shared.onPressed = onPressed;
//     _shared.onLongPress = onLongPress;
//     _shared.gradient = gradient;
//     _shared.padding = padding;
//     _shared.borderRadius = borderRadius;
//     _shared.isExpanded = isExpanded;
//     _shared.boxShadow = boxShadow;
//   }
//   @override
//   _State createState() => _State(this);
// }

class CustomButton extends StatelessWidget {
  final void Function() onPressed;
  final void Function() onLongPress;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final Gradient disabledGradient;
  final bool isExpanded;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> boxShadow;
  final MainAxisAlignment mainAxisAlignment;

  CustomButton({
    Key key,
    this.onPressed,
    this.onLongPress,
    this.padding,
    this.gradient,
    this.disabledGradient,
    this.isExpanded,
    this.borderRadius,
    this.boxShadow,
    this.mainAxisAlignment,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: this.onPressed != null
            ? (this.gradient ?? _Default.gradient)
            : (this.disabledGradient ?? _Default.disabledGradient),
        borderRadius: this.borderRadius,
        boxShadow: this.boxShadow,
      ),
      child: TextButton(
        // padding: EdgeInsets.zero,
        child: Container(
          padding: this.padding ?? _Default.padding,
          constraints: BoxConstraints(
            minWidth: this.isExpanded == true ? double.infinity : 0,
          ),
          child: Row(
            mainAxisAlignment:
                this.mainAxisAlignment ?? _Default.mainAxisAlignment,
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  color: this.onPressed != null ? Color(0xffffffff) : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                child: this.child,
              ),
            ],
          ),
        ),
        onPressed: this.onPressed,
        onLongPress: this.onLongPress,
      ),
    );
  }
}

class LargerCustomButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget heading;
  final Widget content;

  const LargerCustomButton({
    Key key,
    this.onPressed,
    this.heading,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (this.heading is Widget)
      children.add(Expanded(
        child: Theme(
          data: ThemeData(
            iconTheme: IconThemeData(
              color: Color(0xffffffff),
              size: 36,
            ),
            textTheme: Typography.tall2018,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: Color(0xffffffff),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            child: this.heading,
          ),
        ),
        flex: 0,
      ));

    if (this.content is Widget)
      children.add(Expanded(
        child: Theme(
          data: ThemeData(
            iconTheme: IconThemeData(
              color: Color(0xffffffff),
              size: 36,
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: Color(0xffffffff),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            child: this.content,
          ),
        ),
        flex: 2,
      ));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff00cfff),
            Color(0xff008fff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Color(0x6f000000),
            blurRadius: 5,
          ),
        ],
      ),
      width: double.infinity,
      child: TextButton(
        onPressed: this.onPressed,
        // padding: EdgeInsets.all(10),
        child: Row(
          children: children,
        ),
      ),
    );
  }
}
