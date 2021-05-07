import 'package:flutter/widgets.dart';

class _S {
  double size = 10;
  bool needed = true;
}

/// Convert all layout context to widgets with wrapped box container.
List<Widget> _convertToWidgets(List layout) {
  List<Widget> children = [];
  Iterator iterator = layout.iterator;

  iterator.moveNext();

  while (iterator.current != null) {
    _S spacing = _S();

    if (iterator.current is Widget) {
      children.add(
        Row(
          children: [
            Expanded(child: iterator.current),
          ],
        ),
      );
    }

    if (iterator.current is List) {
      Iterator subIter = (iterator.current as List).iterator;
      List<Widget> subCh = [];

      subIter.moveNext();

      while (subIter.current != null) {
        _S subSpacing = _S();

        if (subIter.current is Widget) {
          subCh.add(
            Expanded(
              child: subIter.current,
            ),
          );
        }

        if (subIter.current is Map &&
            (subIter.current as Map)['widget'] is Widget) {
          Map m = subIter.current as Map;
          subCh.add(
            Expanded(
              child: m['widget'],
              flex: m['flex'] ?? 1,
            ),
          );

          if (m['spacingOnNext'] is Map) {
            Map<String, dynamic> attr = m['spacingOnNext'];
            subSpacing.size =
                double.tryParse('${attr['size']}') ?? subSpacing.size;
            subSpacing.needed = attr['needed'] ?? subSpacing.needed;
          }

          if (m['spacingOnNext'] is bool) {
            subSpacing.needed = m['spacingOnNext'];
          }

          // debugPrint(
          //     'SubChildren: ${m['widget'].toString()}; Spacing: ${subSpacing.toString()}|${m['spacingOnNext']}\n}');
        }

        if (subIter.moveNext() && subSpacing.needed) {
          subCh.add(
            Padding(
              padding: EdgeInsets.only(
                left: subSpacing.size,
              ),
            ),
          );
        }
      }

      children.add(
        Row(
          children: subCh,
        ),
      );
    }

    if (iterator.current is Map) {
      Map<String, dynamic> map = iterator.current;

      children.add(
        Row(
          children: [
            Expanded(
              child: map['widget'],
              flex: map['flex'] ?? 1,
            ),
          ],
        ),
      );

      if (map['spacingOnNext'] is Map) {
        Map<String, dynamic> attributes = map['spacingOnNext'];
        spacing.size = double.tryParse('${attributes['size']}') ?? spacing.size;
        spacing.needed = attributes['needed'] ?? spacing.needed;
      }

      if (map['spacingOnNext'] is bool) {
        spacing.needed = map['spacingOnNext'];
      }
    }

    if (iterator.moveNext() && spacing.needed) {
      children.add(
        Padding(
          padding: EdgeInsets.only(
            top: spacing.size,
          ),
        ),
      );
    }
  }

  return children;
}

/// The widget that provide simple layout configuration
/// with simple layout context.
///
/// * The layout context is always a [List] object,
///   meanings of "container" that aligns the items vertically.
///
/// * The member of layout context can be a [Widget],
///   a [Map] instance that must contains a [Widget]
///   (optionally contains some container properties),
///   or a [List] object of "subcontainer" that aligns the items
///   horizontally.
///
/// * The member of "subcontainer" can be a [Widget],
///   or a [Map] instance that must contains a [Widget]
///   (optionally contains some container properties).
class GenericLayout extends StatelessWidget {
  final List<Widget> _children = [];

  GenericLayout(List layout) : super() {
    this._children.addAll(_convertToWidgets(layout));
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
        child: Column(
          children: this._children,
        ),
      );
    } catch (error) {
      return Container();
    }
  }
}
