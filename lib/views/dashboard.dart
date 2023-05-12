import 'dart:async';

import 'package:dorx/models/language.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class Dashboard extends StatefulWidget {
  final bool showDialog;
  Dashboard({
    Key key,
    @required this.showDialog,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  List<Widget> pages;
  int _currentPage = 0;
  PageController _controller;
  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    return UIServices().showDatSheet(
      ExitAppBottomSheet(),
      true,
      context,
      height: MediaQuery.of(context).size.height * 0.7,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _currentPage,
    );

    pages = [ 
      HomeScreen(),
      SavedView(),
      ManageBookingView(),
      Container(),
    ];

    if (widget.showDialog == true) {
      Future(() {
        showDialog(
          context: context,
          builder: (context) {
            return CustomDialogBox(
              bodyText: translation(context).loginOffering,
              buttonText: "Maybe later",
              onButtonTap: () {},
              showSignInButton: true,
              showOtherButton: false,
            );
          },
        );
      });
    }

    PushNotificationService().registerNotification(context);
    PushNotificationService().checkForInitialMessage(context);
    PushNotificationService().onMessageAppListen(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              onPageChanged: (v) {
                setState(() {
                  _currentPage = v;
                });
              },
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              children: pages,
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: [
                  FloatingActionButton.extended(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.explore,
                      );
                    },
                    icon: Icon(
                      FontAwesomeIcons.map,
                    ),
                    label: Text("Map"),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  NavBottomBar(
                    bottomRadius: 50,
                    bottomBarHeight: 60,
                    showBigButton: false,
                    backgroundColor: primaryColor,
                    bigIcon: Icons.add,
                    currentIndex: _currentPage,
                    buttonPosition: ButtonPosition.end,
                    children: [
                      NavIcon(
                        icon: Icons.home,
                        onTap: () {
                          selectTab(0);
                        },
                      ),
                      NavIcon(
                        icon: Icons.favorite,
                        onTap: () {
                          selectTab(1);
                        },
                      ),
                      NavIcon(
                        icon: Icons.bed,
                        onTap: () {
                          selectTab(2);
                        },
                      ),
                      NavIcon(
                        icon: Icons.menu,
                        onTap: () {
                          selectTab(3);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  selectTab(int index) async {
    if (index == pages.length - 1) {
      UIServices().showDatSheet(
        MenuBottomSheet(),
        true,
        context,
      );
    } else {
      _controller.jumpToPage(index);
    }
  }
}
