import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dorx/constants/images.dart';
import 'package:dorx/services/ui_services.dart';

import '../constants/ui.dart';

class NotSignedInView extends StatefulWidget {
  NotSignedInView({
    Key key,
  }) : super(key: key);

  @override
  State<NotSignedInView> createState() => _NotSignedInViewState();
}

class _NotSignedInViewState extends State<NotSignedInView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                loginSvg,
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "You are not logged in.\nPress this button to log in or create an account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  UIServices().showLoginSheet(
                     (v) {},
                    context,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: standardBorderRadius,
                      border: Border.all(width: 1)),
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
