import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dorx/services/communications.dart';

import '../constants/ui.dart';

class ProceedButton extends StatefulWidget {
  final String text;
  final String processingText;
  final BorderRadius borderRadius;
  final Function onTap;
  final bool outlined;
  final Color color;
  final bool enabled;
  final Widget child;
  final bool processing;
  final double textSize;

  ProceedButton({
    Key key,
    @required this.onTap,
    this.text = "Proceed",
    this.outlined = false,
    this.color,
    this.enabled = true,
    this.processingText,
    this.borderRadius,
    this.child,
    this.processing = false,
    this.textSize,
  }) : super(key: key);

  @override
  State<ProceedButton> createState() => _ProceedButtonState();
}

class _ProceedButtonState extends State<ProceedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 5,
        right: 5,
        bottom: 5,
        top: 5,
      ),
      child: GestureDetector(
        onTap: widget.processing
            ? () {
                CommunicationServices().showToast(
                  "Processing. Please wait..",
                  primaryColor,
                );
              }
            : widget.enabled
                ? widget.onTap
                : null,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: widget.outlined != null && widget.outlined
                  ? Border.all(
                      width: 1,
                    )
                  : null,
              color: widget.outlined != null && widget.outlined
                  ? null
                  : widget.enabled
                      ? widget.color ?? primaryColor
                      : Colors.grey,
              borderRadius: widget.borderRadius ?? standardBorderRadius,
            ),
            child: Center(
                child: widget.processing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitWave(
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (widget.processingText != null)
                            Text(
                              widget.processingText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                        ],
                      )
                    : widget.text == null
                        ? widget.child
                        : Text(
                            widget.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ))),
      ),
    );
  }
}
