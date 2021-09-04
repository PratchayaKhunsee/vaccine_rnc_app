library bullet_item_list;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BulletItemList extends StatelessWidget {
  final List<Widget> items;
  final Widget? bulletIcon;

  BulletItemList({
    Key? key,
    required this.items,
    this.bulletIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _bullet = bulletIcon ??
        Text(
          '\u2022',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );

    return Container(
      child: Column(
        children: items
            .map<Container>(
              (e) => Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 3,
                      ),
                      child: _bullet,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 3),
                      child: e,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
