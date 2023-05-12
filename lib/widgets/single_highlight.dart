import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'widgets.dart';

class SingleHighlight extends StatelessWidget {
  final String text;
  final bool selected;
  const SingleHighlight({
    Key key,
    @required this.text,
    @required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: selected ? Colors.green : null,
          borderRadius: standardBorderRadius,
          border: Border.all(
            width: 1,
            color: selected ? Colors.green : Colors.grey,
          )),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            availableHighlights.entries
                .singleWhere(
                  (element) => element.key == text,
                )
                .value,
            color: selected ? Colors.white : null,
          ),
          CustomSizedBox(
            sbSize: SBSize.small,
            height: false,
          ),
          Text(
            text.capitalizeFirstOfEach,
            style: TextStyle(
              color: selected ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}
