library plain_table;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class _Prop {
  bool hasPlainTableAsParent = false;
}

/// The widget of plain table with simple solid monocolor line.
///
/// This will create a table depended on the [children] row-column list.
/// The column of every row in this table will be determined as the maximum size of the row in the [children] list.
///
/// Also, if there is [PlainTable] inside of the [children] list. Its box border(not the line between the columns) will be not created.
///
class PlainTable extends StatelessWidget {
  final List<List<Widget>> children;
  final _Prop _hiddenProperties = _Prop();
  final Color lineColor;
  final double lineWidth;
  final EdgeInsets? cellPadding;

  PlainTable({
    Key? key,
    required this.children,
    this.lineColor = const Color(0xFF000000),
    this.lineWidth = 1,
    this.cellPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Container> rows = [];
    int maxDetectedColumns = 0;
    bool firstRow = true;
    BorderSide line = BorderSide(color: lineColor, width: lineWidth);

    children.forEach((r) {
      maxDetectedColumns =
          r.length > maxDetectedColumns ? r.length : maxDetectedColumns;
    });

    children.forEach((r) {
      List<Container> items = [];

      for (int i = 0; i < maxDetectedColumns; i++) {
        Widget? item = i < r.length ? r[i] : null;
        if (item is PlainTable)
          item._hiddenProperties.hasPlainTableAsParent = true;

        items.add(
          Container(
            decoration: BoxDecoration(
              border: i == 0 ? null : Border(left: line),
            ),
            padding: cellPadding,
            child: item,
          ),
        );
      }

      rows.add(Container(
        decoration: BoxDecoration(
          border: firstRow ? null : Border(top: line),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.map<Expanded>((e) => Expanded(child: e)).toList(),
          ),
        ),
      ));

      firstRow = false;
    });

    return Container(
      decoration: _hiddenProperties.hasPlainTableAsParent
          ? null
          : BoxDecoration(border: Border.fromBorderSide(line)),
      child: Column(
        children: rows,
      ),
    );
  }
}
