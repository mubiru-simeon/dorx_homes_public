import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditUserPrefsBottomSheet extends StatefulWidget {
  const EditUserPrefsBottomSheet({Key key}) : super(key: key);

  @override
  State<EditUserPrefsBottomSheet> createState() =>
      _EditUserPrefsBottomSheetState();
}

class _EditUserPrefsBottomSheetState extends State<EditUserPrefsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Tell us about where you're heading",
        ),
        Expanded(
          child: Column(children: []),
        )
      ],
    );
  }
}
