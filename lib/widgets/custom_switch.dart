import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final String text;
  final bool selected;
  final Function(bool) onTap;
  final IconData icon;
  const CustomSwitch({
    Key key,
    @required this.text,
    @required this.selected,
    @required this.onTap,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Icon(
            icon,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: selected,
            onChanged: (v) {
              onTap(v);
            },
          )
        ],
      ),
    );
  }
}
