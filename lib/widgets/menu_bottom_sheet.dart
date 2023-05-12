import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/constants.dart';
import '../theming/theming.dart';
import 'widgets.dart';

class MenuBottomSheet extends StatefulWidget {
  MenuBottomSheet({Key key}) : super(key: key);

  @override
  State<MenuBottomSheet> createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet> {
  Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSizedBox(
                sbSize: SBSize.smallest,
                height: true,
              ),
              Text(
                capitalizedAppName,
                style: TextStyle(
                  fontSize: 30,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OnlyWhenLoggedIn(
                notSignedIn: Text(
                  "Guest",
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
                signedInBuilder: (uid) {
                  return Text(
                    AuthProvider.of(context)
                            .auth
                            .getCurrentUser()
                            .displayName ??
                        "Ola 😊 How are ya..",
                    style: TextStyle(fontSize: 16, color: primaryColor),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OnlyWhenLoggedIn(
                        notSignedIn: singleDrawerItem(
                          onTap: () {
                            UIServices().showLoginSheet(
                              (v) {},
                              context,
                            );
                          },
                          label: "Click here and Log in to access all features",
                          icon: Icon(
                            Icons.login,
                            size: 25,
                            color: primaryColor,
                          ),
                        ),
                        signedInBuilder: (uid) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomSizedBox(
                                sbSize: SBSize.smallest,
                                height: true,
                              ),
                              Text(
                                "Me",
                                style: TextStyle(fontSize: 17),
                              ),
                              singleDrawerItem(
                                label: "Notifications",
                                onTap: () {
                                  if (AuthProvider.of(context)
                                      .auth
                                      .isSignedIn()) {
                                    context.pushNamed(
                                      RouteConstants.notifications,
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return NotLoggedInDialogBox(
                                          onLoggedIn: (v) {
                                            context.pushNamed(
                                              RouteConstants.notifications,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.notifications,
                                  color: primaryColor,
                                ),
                              ),
                              singleDrawerItem(
                                label: "My Profile",
                                onTap: () {
                                  if (AuthProvider.of(context)
                                      .auth
                                      .isSignedIn()) {
                                    context.pushNamed(
                                      RouteConstants.user,
                                      params: {
                                        "id": AuthProvider.of(context)
                                            .auth
                                            .getCurrentUID()
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return NotLoggedInDialogBox(
                                          onLoggedIn: (v) {
                                            context.pushNamed(
                                              RouteConstants.user,
                                              params: {
                                                "id": v,
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.verified_user,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.normal,
                        height: true,
                      ),
                      Text(
                        "Explore $capitalizedAppName",
                        style: TextStyle(fontSize: 17),
                      ),
                      singleDrawerItem(
                        label: "Categories",
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.categories,
                          );
                        },
                        icon: Icon(
                          Icons.explore,
                          color: primaryColor,
                        ),
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.normal,
                        height: true,
                      ),
                      Text(
                        "Support",
                        style: TextStyle(fontSize: 17),
                      ),
                      singleDrawerItem(
                        label: "Feedback",
                        icon: Icon(
                          Icons.feedback,
                          color: primaryColor,
                        ),
                        onTap: () {
                          FeedbackServices().startFeedingBackward(
                            context,
                          );
                        },
                      ),
                      singleDrawerItem(
                        label: "About $capitalizedAppName",
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.aboutUs,
                          );
                        },
                        icon: Icon(
                          Icons.help,
                          color: primaryColor,
                        ),
                      ),
                      singleDrawerItem(
                        label: "Share $capitalizedAppName",
                        onTap: () {
                          Share.share(
                            'Hey there. I know we probably haven\'t texted in a while, but i just found a revolutionary app i think you\'d reeeally like.. Tap this link $appLinkToPlaystore',
                            subject: 'I found something you may like.',
                          );
                        },
                        icon: Icon(
                          Icons.share,
                          color: primaryColor,
                        ),
                      ),
                      singleDrawerItem(
                        label: "Rate $capitalizedAppName",
                        onTap: () {
                          StorageServices().launchTheThing(
                            appLinkToPlaystore,
                          );
                        },
                        icon: Icon(
                          Icons.star,
                          color: primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CustomSizedBox(
                sbSize: SBSize.small,
                height: false,
              ),
              InkWell(
                onTap: () async {
                  if (AuthProvider.of(context).auth.isSignedIn()) {
                    try {
                      await AuthProvider.of(context).auth.signOut();
                    } catch (e) {
                      CommunicationServices().showToast(
                        "There was an error logging you out. ${e.toString()}",
                        Colors.blue,
                      );
                    }
                  } else {
                    UIServices().showLoginSheet(
                      (v) {},
                      context,
                    );
                  }
                },
                child: OnlyWhenLoggedIn(
                  notSignedIn: Text(
                    'Log In',
                    style: TextStyle(
                        //color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  signedInBuilder: (uid) {
                    return Text(
                      translation(context).logOut,
                      style: TextStyle(
                          //color: Colors.white,
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: false,
              ),
              Container(
                width: 2,
                height: 20,
                color: ThemeBuilder.of(context).getCurrentTheme() ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: false,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: standardBorderRadius,
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: SwitcherButton(
                  size: 60,
                  value: ThemeBuilder.of(context).getCurrentTheme() ==
                      Brightness.light,
                  onChange: (v) async {
                    if (v) {
                      //light
                      ThemeBuilder.of(context).makeLight();

                      box.put(
                        sharedPrefBrightness,
                        "light",
                      );
                    } else {
                      //dark
                      ThemeBuilder.of(context).makeDark();

                      box.put(
                        sharedPrefBrightness,
                        "dark",
                      );
                    }
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  singleDrawerItem({
    @required String label,
    String image,
    @required Function onTap,
    @required Icon icon,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                image == null
                    ? icon
                    : CircleAvatar(
                        child: SingleImage(
                          image: image,
                        ),
                      ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: false,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 5,
          )
        ],
      ),
    );
  }
}
