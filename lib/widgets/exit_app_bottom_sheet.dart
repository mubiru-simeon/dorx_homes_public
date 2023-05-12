import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets.dart';

class ExitAppBottomSheet extends StatefulWidget {
  ExitAppBottomSheet({Key key}) : super(key: key);

  @override
  State<ExitAppBottomSheet> createState() => _ExitAppBottomSheetState();
}

class _ExitAppBottomSheetState extends State<ExitAppBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Exit $capitalizedAppName?",
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Are you sure you want to exit $capitalizedAppName.",
            style: darkTitle
          ),
          Spacer(),
          ProceedButton(
            onTap: () {
              SystemNavigator.pop();
            },
            text: "Yes. Exit $capitalizedAppName",
          )
        ],
      ),
    );
  }
}
