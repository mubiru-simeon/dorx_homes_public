import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'widgets.dart';

class BackBar extends StatelessWidget {
  final String text;
  final bool showIcon;
  final Function onPressed;
  final Widget action;
  final IconData icon;

  BackBar({
    Key key,
    @required this.icon,
    this.showIcon = true,
    @required this.onPressed,
    @required this.text,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = 20;

    return Stack(
      children: [
        Container(
          color: altColor,
          child: Column(
            children: [
              SafeArea(
                child: SizedBox(),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 2,
                ),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    showIcon
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: onPressed ??
                                  () {
                                    if (context.canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      context.pushReplacementNamed(
                                        RouteConstants.home,
                                      );
                                    }
                                  },
                              child: CircleAvatar(
                                child: IconButton(
                                  icon: Icon(
                                    icon ?? Icons.arrow_back_ios_rounded,
                                  ),
                                  onPressed: onPressed ??
                                      () {
                                        if (context.canPop()) {
                                          Navigator.of(context).pop();
                                        } else {
                                          context.pushReplacementNamed(
                                            RouteConstants.home,
                                          );
                                        }
                                      },
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 20,
                          ),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (action != null) action,
                    SizedBox(
                      width: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.aboutUs,
                            );
                          },
                          child: CircleAvatar(
                            child: SingleImage(
                              image: homesLogoLight,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            UIServices().showDatSheet(
                              LanguageChangerBottomSheet(),
                              true,
                              context,
                            );
                          },
                          child: Icon(
                            Icons.language,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            FeedbackServices().startFeedingBackward(context);
                          },
                          child: Icon(
                            Icons.feedback,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height,
              )
            ],
          ),
        ),
        Positioned(
          bottom: -2,
          left: 0,
          right: 0,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  50,
                ),
                topRight: Radius.circular(
                  50,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
