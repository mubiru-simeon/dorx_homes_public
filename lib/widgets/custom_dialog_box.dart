import 'package:dorx/models/language.dart';
import 'package:flutter/material.dart';
import 'package:dorx/constants/basic.dart';
import 'package:dorx/constants/images.dart';
import 'package:dorx/constants/ui.dart';

import '../services/services.dart';
import 'custom_sized_box.dart';

class CustomDialogBox extends StatefulWidget {
  final String bodyText;
  final bool showSignInButton;
  final bool showOtherButton;
  final String buttonText;
  final List<String> bullets;
  final Function onButtonTap;
  final String afterBullets;
  final Widget child;
  final Function(String) onLoggedIn;

  CustomDialogBox({
    Key key,
    this.showSignInButton = false,
    @required this.bodyText,
    @required this.buttonText,
    this.onLoggedIn,
    @required this.onButtonTap,
    @required this.showOtherButton,
    this.afterBullets,
    this.bullets,
    this.child,
  }) : super(key: key);

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    width: 80,
                    height: 80,
                    image: AssetImage(
                      homesLogo,
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.smallest,
                    height: false,
                  ),
                  Text(
                    capitalizedAppName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CustomSizedBox(
                sbSize: SBSize.smallest,
                height: true,
              ),
              if (widget.child != null) widget.child,
              if (widget.child == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.bodyText ??
                          "You need to Log in or create an account to use this feature. Press the button below to Log in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    CustomSizedBox(
                      sbSize: SBSize.smallest,
                      height: true,
                    ),
                    if (widget.bullets != null && widget.bullets.isNotEmpty)
                      Column(
                        children: widget.bullets.map((e) {
                          return Padding(
                            padding: EdgeInsets.all(3),
                            child: Row(
                              children: [
                                Text("-"),
                                CustomSizedBox(
                                  sbSize: SBSize.smallest,
                                  height: false,
                                ),
                                Expanded(
                                  child: Text(
                                    e,
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    CustomSizedBox(
                      sbSize: SBSize.smallest,
                      height: true,
                    ),
                    if (widget.afterBullets != null)
                      Text(
                        widget.afterBullets,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    CustomSizedBox(
                      sbSize: SBSize.smallest,
                      height: true,
                    ),
                  ],
                ),
              if (widget.child == null)
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: true,
                ),
              if (widget.child == null)
                if (widget.showSignInButton)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();

                      UIServices().showLoginSheet(
                        (v) {
                          if (widget.onLoggedIn != null) {
                            widget.onLoggedIn(v);
                          }
                        },
                        context,
                      );
                    },
                    child: Material(
                      borderRadius: standardBorderRadius,
                      elevation: standardElevation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: standardBorderRadius,
                        ),
                        child: Text(
                          "${translation(context).signIn} / ${translation(context).getStarted}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: true,
              ),
              if (widget.child == null)
                if (widget.showOtherButton)
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();

                      widget.onButtonTap();
                    },
                    child: Material(
                      borderRadius: standardBorderRadius,
                      elevation: standardElevation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: standardBorderRadius,
                        ),
                        child: Text(
                          widget.buttonText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              if (widget.child == null)
                if (widget.showSignInButton)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Text(
                        translation(context).maybeLater,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
