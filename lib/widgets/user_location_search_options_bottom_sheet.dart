import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';

class UserLocationSearchOptionsBottomSheet extends StatefulWidget {
  const UserLocationSearchOptionsBottomSheet({Key key}) : super(key: key);

  @override
  State<UserLocationSearchOptionsBottomSheet> createState() =>
      _UserLocationSearchOptionsBottomSheetState();
}

class _UserLocationSearchOptionsBottomSheetState
    extends State<UserLocationSearchOptionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Where, when and who?",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [],
            ),
          ),
        )
      ],
    );
  }
}
