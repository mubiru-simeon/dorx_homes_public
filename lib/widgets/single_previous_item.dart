import 'package:flutter/cupertino.dart';
import 'package:dorx/models/thing_type.dart';
import '../models/models.dart';
import 'widgets.dart';

class SinglePreviousItem extends StatelessWidget {
  final String usableThingID;
  final String type;
  final bool selectable;
  final bool list;
  final bool selected;
  final String searchedText;
  final bool sized;
  final bool simple;
  final bool sensitive;
  final bool showButton;
  final bool horizontal;
  final Function onTap;

  const SinglePreviousItem({
    Key key,
    @required this.usableThingID,
    @required this.type,
    this.selected = false,
    this.simple,
    this.horizontal = true,
    this.sensitive = false,
    this.selectable = false,
    this.showButton = true,
    this.sized = false,
    this.searchedText = "]",
    this.list = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return type == ThingType.USER
        ? Container(
            constraints: BoxConstraints(
              maxWidth: horizontal
                  ? MediaQuery.of(context).size.width * 0.7
                  : MediaQuery.of(context).size.width,
            ),
            child: Stack(
              children: [
                SingleUser(
                  user: null,
                  onTap: onTap,
                  userID: usableThingID,
                ),
                if (selected) SelectorThingie()
              ],
            ),
          )
        : Text(type);
  }
}
