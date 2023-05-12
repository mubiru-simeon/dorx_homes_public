import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AboutUs extends StatefulWidget {
  AboutUs({
    Key key,
  }) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "About $capitalizedAppName",
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                              height: 100,
                              image: AssetImage(
                                dorxLogo,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    capitalizedAppName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.purple,
                                      fontSize: 25,
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Version $versionNumber",
                                style: TextStyle(
                                  //fontWeight: FontWeight.w700,
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.small,
                    height: true,
                  ),
                  Text(
                    appCatchPhrase,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.small,
                    height: true,
                  ),
                  Text(
                    simeonMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.small,
                    height: true,
                  ),
                  Text(
                    simeonCredits,
                    textAlign: TextAlign.center,
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.small,
                    height: true,
                  ),
                  CustomDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.phone,
                    ),
                    title: Text(
                      "Contact the Developer",
                    ),
                    onTap: () async {
                      StorageServices().launchTheThing("tel:$dorxPhoneNumber");
                    },
                  ),
                  CustomDivider()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
