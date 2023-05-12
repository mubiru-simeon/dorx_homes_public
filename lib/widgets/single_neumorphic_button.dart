import 'package:flutter/material.dart';

import '../constants/ui.dart';

class SingleNeumorphicButton extends StatelessWidget {
  final double radius;
  final Widget child;
  final Function onTap;
  SingleNeumorphicButton({
    Key key,
    @required this.child,
    @required this.onTap,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: radius == null
              ? standardBorderRadius
              : BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 4)),
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: Offset(
                -4,
                -4,
              ),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
