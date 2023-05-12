// ignore_for_file: unnecessary_this

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonController {
  double buttonHeight;
  Color buttonColor;
  Color buttonTextColor;
  bool processing;
  String buttonText;
  double slideButtonMargin;
  Color slideButtonColor;
  Color slideButtonIconColor;
  IconData slideButtonIcon;
  double slideButtonMarginDragOffset;
  double slideButtonIconSize;
  double radius;
  double successfulThreshold;
  Widget widgetWhenSlideIsCompleted;
  VoidCallback onSlideSuccessCallback;
  bool isSlideEnabled;
  double slideButtonSize;
  bool isSlideStarted;

  ButtonController({
    this.buttonTextColor = Colors.white,
    this.buttonText = 'Slide to confirm...',
    this.slideButtonMargin = 7.5,
    this.slideButtonColor = Colors.white,
    this.slideButtonIconColor = Colors.green,
    this.slideButtonIcon = Icons.chevron_right,
    this.slideButtonIconSize = 30.0,
    this.radius = 4.0,
    this.successfulThreshold = 0.9,
    this.widgetWhenSlideIsCompleted,
    this.onSlideSuccessCallback,
    this.buttonColor = Colors.pink,
    this.buttonHeight = 55,
    this.processing = false,
    this.isSlideEnabled = false,
    this.isSlideStarted = false,
    this.slideButtonSize,
    this.slideButtonMarginDragOffset = 0,
  });

  void reset() {
    resetSlideButton();

    this.slideButtonMarginDragOffset = 0;
    this.isSlideEnabled = false;
    this.isSlideStarted = false;
  }

  resetSlideButton() {
    slideButtonSize = buttonHeight - (slideButtonMargin * 2);
    slideButtonMargin = slideButtonMargin;
  }
}

class SlidingButton extends StatefulWidget {
  final ButtonController controller;
  final bool processing;

  SlidingButton({
    Key key,
    this.controller,
    @required this.processing,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SlidingButtonState();
}

class SlidingButtonState extends State<SlidingButton> {
  final _buttonKey = GlobalKey();
  final _slideButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.slideButtonSize = widget.controller.buttonHeight -
        (widget.controller.slideButtonMargin * 2);
    widget.controller.slideButtonMargin = widget.controller.slideButtonMargin;
    widget.controller.widgetWhenSlideIsCompleted =
        widget.controller.widgetWhenSlideIsCompleted ??= Center(
      child: SizedBox(
        width: widget.controller.buttonHeight / 3,
        height: widget.controller.buttonHeight / 3,
        child: PlatformProgressIndicator(
          materialValueColor: AlwaysStoppedAnimation<Color>(
              widget.controller.slideButtonIconColor),
          materialStrokeWidth: 1.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.processing,
      child: GestureDetector(
        onTapDown: (tapDetails) {
          // Check if the tap down event has occurred inside the slide button
          final RenderBox renderBox =
              _slideButtonKey.currentContext.findRenderObject();
          final slideButtonOffset = renderBox.localToGlobal(Offset.zero);
          // On all positions I've added the _slideButtonMargin. Basically we use the _slideButtonMargin as a invisible touchable area that triggers the slide event
          final startXPosition =
              slideButtonOffset.dx - widget.controller.slideButtonMargin;
          final endXPosition = startXPosition +
              widget.controller.buttonHeight +
              widget.controller.slideButtonMargin;
          final startYPosition =
              slideButtonOffset.dy - widget.controller.slideButtonMargin;
          final endYPosition = startYPosition +
              widget.controller.buttonHeight +
              widget.controller.slideButtonMargin;
          // We only enable the slide gesture if the tap occurs inside the slide button
          if ((tapDetails.globalPosition.dx >= startXPosition &&
                  tapDetails.globalPosition.dx <= endXPosition) &&
              (tapDetails.globalPosition.dy >= startYPosition &&
                  tapDetails.globalPosition.dy <= endYPosition)) {
            widget.controller.isSlideEnabled = true;
            widget.controller.slideButtonSize = widget.controller.buttonHeight;
            widget.controller.slideButtonMargin = 0;
            setState(() {});
          } else {
            widget.controller.isSlideEnabled = false;
            widget.controller.isSlideStarted = false;
          }
        },
        onTapUp: (details) {
          widget.controller.isSlideEnabled = false;
          widget.controller.resetSlideButton();
          setState(() {});
        },
        onTapCancel: () {
          if (!widget.controller.isSlideEnabled) {
            widget.controller.isSlideEnabled = false;
            widget.controller.resetSlideButton();

            setState(() {});
          }
        },
        onHorizontalDragStart: (dragDetails) {
          if (widget.controller.isSlideEnabled) {
            widget.controller.isSlideStarted = true;
            widget.controller.slideButtonSize = widget.controller.buttonHeight +
                widget.controller.slideButtonMarginDragOffset;
            widget.controller.slideButtonMargin = 0;

            setState(() {});
          }
        },
        onHorizontalDragUpdate: (dragUpdateDetails) {
          if (widget.controller.isSlideStarted) {
            widget.controller.slideButtonMarginDragOffset +=
                dragUpdateDetails.delta.dx;
            widget.controller.slideButtonSize = widget.controller.buttonHeight +
                widget.controller.slideButtonMarginDragOffset;
            widget.controller.slideButtonMargin = 0;
            // Check for minimum values that must be respected. We don't animate the slide button below the minimum.
            widget.controller.slideButtonMarginDragOffset =
                widget.controller.slideButtonMarginDragOffset < 0
                    ? 0
                    : widget.controller.slideButtonMarginDragOffset;
            widget.controller.slideButtonSize =
                widget.controller.slideButtonSize <
                        widget.controller.buttonHeight
                    ? widget.controller.buttonHeight
                    : widget.controller.slideButtonSize;
            setState(() {});
          }
        },
        onHorizontalDragCancel: () {
          widget.controller.isSlideStarted = false;
          widget.controller.isSlideEnabled = false;
          widget.controller.resetSlideButton();
          setState(() {});
        },
        onHorizontalDragEnd: (dragDetails) {
          if (widget.controller.isSlideEnabled ||
              widget.controller.isSlideStarted) {
            final RenderBox renderBox =
                _buttonKey.currentContext.findRenderObject();
            if (widget.controller.slideButtonSize >=
                widget.controller.successfulThreshold * renderBox.size.width) {
              widget.controller.slideButtonSize = renderBox.size.width;
              widget.controller.isSlideEnabled = false;
              widget.controller.isSlideStarted = false;
              widget.controller.onSlideSuccessCallback?.call();
            } else {
              widget.controller.slideButtonMarginDragOffset = 0;
              widget.controller.resetSlideButton();
            }
            setState(() {});
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: widget.controller.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              widget.controller.radius,
            ),
          ),
          elevation: 4,
          child: SizedBox(
            key: _buttonKey,
            width: double.infinity,
            height: widget.controller.buttonHeight,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    margin: EdgeInsets.only(
                      left: (widget.controller.slideButtonMargin / 2) +
                          widget.controller.buttonHeight,
                    ),
                    child: Text(
                      widget.controller.buttonText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.controller.buttonTextColor,
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  key: _slideButtonKey,
                  margin: EdgeInsets.only(
                    left: widget.controller.slideButtonMargin,
                    top: widget.controller.slideButtonMargin,
                  ),
                  duration: Duration(milliseconds: 100),
                  width: widget.controller.slideButtonSize,
                  height: widget.controller.slideButtonSize,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(widget.controller.radius),
                    color: widget.controller.slideButtonColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.controller.slideButtonIcon,
                      color: widget.controller.slideButtonIconColor,
                      size: widget.controller.slideButtonIconSize,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: widget.processing ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    height: widget.controller.buttonHeight,
                    color: widget.controller.slideButtonColor,
                    child: Center(
                      child: widget.controller.widgetWhenSlideIsCompleted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlatformProgressIndicator extends StatelessWidget {
  PlatformProgressIndicator({
    Key key,
    this.large = false,
    this.materialStrokeWidth = 4.0,
    this.materialValueColor,
  }) : super(key: key);

  final bool large;
  final double materialStrokeWidth;
  final Animation<Color> materialValueColor;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        radius: large ? 15.0 : 10.0,
      );
    } else {
      return CircularProgressIndicator(
        strokeWidth: materialStrokeWidth,
        valueColor: materialValueColor,
      );
    }
  }
}
