import 'dart:async';

import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:dorx/widgets/pulser.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../services/services.dart';

class SplashScreenView extends StatefulWidget {
  SplashScreenView({Key key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  Box box;
  bool finishedOnboarding;

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);
    startTime();
  }

  void navigationPage() async {
    finishedOnboarding = box.get(DorxSettings.FINISHEDONBOARDING) ?? false;

    context.pushReplacementNamed(
      finishedOnboarding ? RouteConstants.home : RouteConstants.onboarding1,
    );
  }

  startTime() async {
    var duration = Duration(seconds: 5);
    return Timer(duration, navigationPage);
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider.of(context).auth.reloadAccount(context);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Center(
                child: Pulser(
                  duration: 800,
                  child: Image(
                    width: MediaQuery.of(context).size.width * 0.4,
                    image: AssetImage(
                      homesLogoLight,
                    ),
                  ),
                ),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
