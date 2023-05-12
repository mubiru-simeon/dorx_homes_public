import 'package:flutter/material.dart';

class StackableScrollController extends StatefulWidget {
  final ScrollController controller;

  const StackableScrollController({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StackableScrollController> createState() =>
      _StackableScrollControllerState();
}

class _StackableScrollControllerState extends State<StackableScrollController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {
            widget.controller.animateTo(
              widget.controller.offset - 300,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          },
          child: CircleAvatar(
            child: Icon(
              Icons.keyboard_arrow_left,
            ),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            widget.controller.animateTo(
              widget.controller.offset + 300,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          },
          child: CircleAvatar(
            child: Icon(
              Icons.keyboard_arrow_right,
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
