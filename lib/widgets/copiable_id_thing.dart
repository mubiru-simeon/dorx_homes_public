import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../services/services.dart';

class CopiableIDThing extends StatelessWidget {
  final String id;
  final IconData iconData;
  final String thing;
  const CopiableIDThing({
    Key key,
    @required this.id,
    this.thing = "ID",
    this.iconData = Icons.copy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(
          ClipboardData(
            text: id,
          ),
        );

        CommunicationServices().showToast(
          "Successfully copied the $thing.",
          primaryColor,
        );
      },
      child: Row(
        children: [
          Icon(
            iconData,
            size: 15,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              "$thing (Tap here to copy):\n$id",
            ),
          ),
        ],
      ),
    );
  }
}
