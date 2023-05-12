//Big Button Position
import 'package:flutter/material.dart';

import '../../../constants/ui.dart';

enum ButtonPosition { start, center, end }

class NavBottomBar extends StatefulWidget {
  //Children class to classify widgets
  final List<NavIcon> children;
  //init index(required)
  final int currentIndex;
  //Big Button Position
  final ButtonPosition buttonPosition;
  //Background color of Big Container
  final Color backgroundColor;
  //To Show Big Button(Default true)
  final bool showBigButton;
  //Big Button Ontap
  final Function() btnOntap;
  //Big Button Icon Color
  final Color bigIconColor;
  //Big Icon
  final IconData bigIcon;
  //height of big container(default 80)
  final double bottomBarHeight;
  //width of big container(default size.width * 0.9)
  final double bottomBarWidth;
  //Radius of Radius
  final double bottomRadius;
  //Decoration of Box
  final BoxDecoration decoration;

  NavBottomBar({
    Key key,
    @required this.children,
    @required this.currentIndex,
    this.bigIcon,
    this.buttonPosition = ButtonPosition.center,
    this.backgroundColor,
    this.bottomBarHeight = 80,
    this.bottomBarWidth,
    this.bottomRadius = 35,
    this.showBigButton = true,
    this.btnOntap,
    this.bigIconColor,
    this.decoration,
  }) : super(key: key);

  @override
  State<NavBottomBar> createState() => _NavBottomBarState();
}

class _NavBottomBarState extends State<NavBottomBar> {
  //to Arrage Space for Big Icon
  List<Widget> _getChildren() {
    List<Widget> children = [];
    int middle = (widget.children.length / 2).ceil();
    int index = 0;
    for (NavIcon el in widget.children) {
      int i = widget.children.indexOf(el);
      NavIcon icon = NavIcon(
        activecolor: el.activecolor,
        icon: el.icon,
        onTap: () {
          el.onTap();
        },
        isActive: widget.currentIndex == i,
        color: el.color,
      );
      children.add(icon);
      index++;
      if (index == middle &&
          widget.buttonPosition == ButtonPosition.center &&
          widget.showBigButton) {
        children.add(_getShowButton());
      }
    }
    if (widget.buttonPosition == ButtonPosition.end && widget.showBigButton) {
      children.add(_getShowButton());
    }
    if (widget.buttonPosition == ButtonPosition.start && widget.showBigButton) {
      children.insert(0, _getShowButton());
    }
    return children;
  }

  //Big Button
  Widget _getShowButton() {
    return FloatingActionButton(
      heroTag: null,
      elevation: 0.0,
      backgroundColor: widget.bigIconColor ?? Colors.blue,
      onPressed: widget.btnOntap,
      child: Icon(
        widget.bigIcon,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: widget.bottomBarHeight,
          width: widget.bottomBarWidth ?? (size.width * 0.9),
          decoration: widget.decoration ??
              BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    widget.bottomRadius,
                  ),
                ),
                color: widget.backgroundColor ?? Colors.black54,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(4, 4),
                      blurRadius: 10.0),
                ],
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _getChildren(),
          ),
        ),
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  //this is the color of icon(default color will be white)
  final Color color;
  //Icon
  final IconData icon;
  //Add on tap function
  final Function() onTap;
  //Active will add animated color under icon
  final bool isActive;
  //Active Color
  final Color activecolor;
  //Animation
  final Curve curve;

  const NavIcon({
    Key key,
    this.color = Colors.white,
    @required this.icon,
    this.onTap,
    this.isActive = false,
    this.activecolor = Colors.blue,
    this.curve = Curves.bounceIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            icon,
            size: isActive == true ? 32 : 30,
            color: color.withOpacity(isActive == true ? 1 : 0.5),
          ),
          onPressed: onTap,
        ),
        AnimatedContainer(
          width: isActive == true ? 10.0 : 0.0,
          height: isActive == true ? 5.0 : 0.0,
          decoration: BoxDecoration(
            color:
                // ignore: unnecessary_this
                this.isActive == true ? this.activecolor : Colors.transparent,
            borderRadius: standardBorderRadius,
          ),
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceIn,
        )
      ],
    );
  }
}
