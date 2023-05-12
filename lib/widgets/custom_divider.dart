import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double width;
  CustomDivider({
    Key key,
    this.height,
    this.width,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.grey,
      height: 1,
      padding: height != null ? EdgeInsets.symmetric(vertical: 20) : null,
      width: width ?? MediaQuery.of(context).size.width,
    );
  }
}

class GreyDivider extends StatelessWidget {
  const GreyDivider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.5),
      height: 15,
      width: MediaQuery.of(context).size.width,
    );
  }
}
