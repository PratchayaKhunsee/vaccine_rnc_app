library simple_layout;

import 'package:flutter/material.dart';

/// The basic document layout widget.
///
/// It can determine how to render widget to the simple layout widget by
/// [Line] widgets, [Item] widgets and some properties.
class SimpleLayout extends StatelessWidget {
  /// The spacing between lines.
  final double lineSpacing;

  /// The spacing between items.
  final double itemSpacing;

  /// The list of [Line] widget.
  final List<Line>? lines;

  SimpleLayout({
    Key? key,
    this.lineSpacing = 10,
    this.itemSpacing = 10,
    this.lines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> builtWidgets = <Widget>[];
    Iterator<Line> li = lines!.iterator;
    Line? previousLine = null;
    while (li.moveNext()) {
      Line currentLine = li.current;
      builtWidgets.add(Container(
        padding: previousLine != null
            ? EdgeInsets.only(
                top: previousLine.nextLineSpacing ?? itemSpacing,
              )
            : null,
        child: currentLine,
      ));
      previousLine = currentLine;
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: builtWidgets,
      ),
    );
  }
}

/// The line inside of [SimpleLayout]
class Line extends StatelessWidget {
  /// The spacing between items. If there is no number of it,
  /// the spacing is determined by the parent [SimpleLayout.itemSpacing] property instead.
  final double? itemSpacing;

  /// The spacing between this and the next line. If there is no number of it,
  /// the spacing is determined by the parent [SimpleLayout.lineSpacing] property instead.
  final double? nextLineSpacing;

  /// List of [Item] widget.
  final List<Item>? items;

  /// Insteadly render the [Line] widget as a line and the only child widget inside of it.
  final Widget? child;

  Line({
    Key? key,
    this.itemSpacing,
    this.nextLineSpacing,
    this.items,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(
        child: child,
      );
    }

    List<Widget> builtWidgets = <Widget>[];
    Iterator<Item> it = items!.iterator;
    Item? previousItem = null;
    while (it.moveNext()) {
      Item currentItem = it.current;
      builtWidgets.add(Container(
        padding: previousItem != null
            ? EdgeInsets.only(
                left: previousItem.nextItemSpacing ??
                    context
                        .findAncestorWidgetOfExactType<SimpleLayout>()!
                        .itemSpacing,
              )
            : null,
        child: currentItem,
      ));
      previousItem = currentItem;
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: builtWidgets,
      ),
    );
  }
}

/// The item inside of [Line] and [SimpleLayout].
class Item extends StatelessWidget {
  /// The spacing between this and the next item. If there is no number of it,
  /// the spacing is determine by the anchestor [SimpleLayout.itemSpacing] property instead.
  final double? nextItemSpacing;

  /// The widget inside of this.
  final Widget? child;

  Item({
    Key? key,
    this.nextItemSpacing,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
