import 'package:flutter/material.dart';

import 'custom_sized_box.dart';

class OrDivider extends StatelessWidget {
  final Color color;
  final bool vertical;
  final String text;
  final double height;
  const OrDivider({
    Key key,
    this.color = Colors.grey,
    this.vertical = false,
    this.height = 100,
    this.text = "OR",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return vertical
        ? SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Column(children: [
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: true,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                  ),
                ),
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: true,
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ]),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                ),
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: false,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                  ),
                ),
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: false,
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 2,
                  ),
                ),
              ],
            ),
          );
  }
}
