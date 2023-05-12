import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';
import '../constants/constants.dart';
import '../models/models.dart';

import 'package:http/http.dart' as http;
import '../widgets/widgets.dart';
import 'services.dart';

enum AuthFormType { signIn, signUp }

class NewLoginSheet extends StatefulWidget {
  final Function(String) doAfterWards;

  const NewLoginSheet({
    Key key,
    @required this.doAfterWards,
  }) : super(key: key);

  @override
  State<NewLoginSheet> createState() => _NewLoginSheetState();
}

class _NewLoginSheetState extends State<NewLoginSheet> {
  AuthFormType authFormType = AuthFormType.signUp;
  TextEditingController userNameController;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool processing = false;
  String processingText;
  String _warning;
  Color bgColor = Colors.red;
  FocusNode passwordFocusNode = FocusNode();
  FocusNode userNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  List<Widget> pages;
  bool visible = false;
  PageController pageController = PageController();
  int _currentIndex = 0;
  Box box;
  String university;

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);
    university = box.get(UserModel.UNIVERSITY);

    String nn = box.get(UserModel.USERNAME);
    userNameController = TextEditingController(
      text: nn,
    );

    emailFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      emailPage(),
      passwordPage(),
      if (authFormType == AuthFormType.signUp) namePage(),
    ];

    return WillPopScope(
      onWillPop: () {
        return handleBackButton();
      },
      child: Scaffold(
        body: MyKeyboardListenerWidget(
          proceed: () {
            checkIfItsSafeToProceed();
          },
          child: Column(
            children: [
              BackBar(
                icon: _currentIndex == 0 ? Icons.close : null,
                onPressed: _currentIndex == 0
                    ? null
                    : () {
                        goBack();
                      },
                text: translation(context).signIn,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: pages.map((e) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 1,
                        ),
                        height: 5,
                        color: _currentIndex >= pages.indexOf(e)
                            ? primaryColor
                            : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_warning != null)
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  color: bgColor,
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.smallest,
                        height: false,
                      ),
                      Expanded(
                        child: Text(
                          _warning,
                          maxLines: 5,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              _warning = null;
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (v) {
                      setState(() {
                        _currentIndex = v;
                      });
                    },
                    controller: pageController,
                    children: pages,
                  ),
                ),
              ),
              ProceedButton(
                processingText: processingText,
                processing: processing,
                onTap: () {
                  checkIfItsSafeToProceed();
                },
                text: translation(context).proceed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  checkIfItsSafeToProceed() {
    if (_currentIndex == 0 && emailController.text.trim().isEmpty) {
      CommunicationServices().showToast(
        translation(context).youNeedToProvideEmail,
        Colors.red,
      );
    } else {
      if (_currentIndex == 1 && passwordController.text.trim().isEmpty) {
        CommunicationServices().showSnackBar(
          translation(context).youNeedToProvideEmail,
          context,
        );
      } else {
        if (_currentIndex == 1 &&
            authFormType == AuthFormType.signUp &&
            confirmPasswordController.text.trim().isEmpty) {
          CommunicationServices().showSnackBar(
            translation(context).youNeedToProvidePassword,
            context,
          );
        } else {
          if (_currentIndex == 1 &&
              authFormType == AuthFormType.signUp &&
              passwordController.text.trim() !=
                  confirmPasswordController.text.trim()) {
            CommunicationServices().showSnackBar(
              translation(context).yourPasswordsDontMatch,
              context,
            );
          } else {
            if (_currentIndex == 2 && userNameController.text.trim().isEmpty) {
              CommunicationServices().showSnackBar(
                translation(context).youNeedToProvideName,
                context,
              );
            } else {
              pp();
            }
          }
        }
      }
    }
  }

  Future<List<UserModel>> checkForUserAccountsWithEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection(UserModel.DIRECTORY)
        .where(UserModel.EMAIL, isEqualTo: email)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        return [];
      } else {
        List<UserModel> pp = [];

        for (var element in value.docs) {
          pp.add(UserModel.fromSnapshot(element));
        }

        return pp;
      }
    });
  }

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      // Fetch sign-in methods for the email address
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      if (list.isNotEmpty) {
        // Return true because there is an existing
        // user using the email address
        return true;
      } else {
        // Return false because email adress is not in use
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  pp() async {
    if (processing) {
      CommunicationServices().showSnackBar(
        translation(context).justASecWaitYouCanCancel,
        context,
        behavior: SnackBarBehavior.floating,
        buttonText: translation(context).cancel,
        whatToDo: () {
          if (mounted) {
            setState(() {
              processing = false;
            });
          }
        },
      );
    } else {
      if (_currentIndex == 0) {
        setState(() {
          processing = true;
          processingText = translation(context).checkingEmail;
        });

        bool result = await checkIfEmailInUse(emailController.text.trim());

        processing = false;
        if (result) {
          authFormType = AuthFormType.signIn;
        } else {
          authFormType = AuthFormType.signUp;
        }

        goNext();
      } else {
        if (_currentIndex == 1) {
          if (authFormType == AuthFormType.signIn) {
            setState(() {
              processing = true;
              processingText = translation(context).signingIn;
            });

            signIn();
          } else {
            goNext();
          }
        } else {
          if (_currentIndex == 2) {
            setState(() {
              processing = true;
              processingText = translation(context).checkingEmail;
            });

            List<UserModel> accts = await checkForUserAccountsWithEmail(
                emailController.text.trim());

            if (accts.isEmpty) {
              signUp();
            } else {
              if (accts.length == 1) {
                setState(() {
                  processing = true;
                  userNameController = TextEditingController(
                    text: accts[0].userName,
                  );
                  processingText = translation(context).creatingAccount;
                });

                String cc = await createAccountThenSignIn(
                  emailController.text.trim(),
                  userNameController.text.trim(),
                  passwordController.text.trim(),
                  accts[0].id,
                );

                if (cc == null) {
                  signIn();
                } else {
                  setState(() {
                    processing = false;
                  });

                  showDialog(
                    context: context,
                    builder: (context) {
                      return CustomDialogBox(
                        bodyText:
                            "$cc.\n\n${translation(context).ifYouNeedHelp}",
                        buttonText: translation(context).pressHereToCallUs,
                        onButtonTap: () {
                          StorageServices().launchTheThing(
                            "tel:$dorxPhoneNumber",
                          );
                        },
                        showOtherButton: true,
                      );
                    },
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CustomDialogBox(
                      bodyText:
                          "${translation(context).yourEmailHasTwoOrMore}.\n\n${translation(context).ifYouNeedHelp}",
                      buttonText: translation(context).pressHereToCallUs,
                      onButtonTap: () {
                        StorageServices()
                            .launchTheThing("tel:$dorxPhoneNumber");
                      },
                      showOtherButton: true,
                    );
                  },
                );
              }
            }
          }
        }
      }
    }
  }

  Future<String> createAccountThenSignIn(
    String email,
    String userName,
    String password,
    String uid,
  ) async {
    final response = await http.post(
      Uri.parse(
        'https://us-central1-dorx-super-app.cloudfunctions.net/createUser',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'email': email,
          "username": userName,
          'password': password,
          'uid': uid,
        },
      ),
    );
    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  handleBackButton() {
    if (_currentIndex != 0) {
      goBack();
    } else {
      Navigator.of(context).pop();
    }
  }

  goNext() {
    if (pageController.page == 0) {
      passwordFocusNode.requestFocus();
    } else {
      if (pageController.page == 1) {
        userNameFocusNode.requestFocus();
      }
    }

    pageController.animateToPage(
      (pageController.page + 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  goBack() {
    if (pageController.page == 1) {
      emailFocusNode.requestFocus();
    } else {
      if (pageController.page == 2) {
        passwordFocusNode.requestFocus();
      }
    }

    pageController.animateToPage(
      (pageController.page - 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  emailPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          StatisticText(
            title: translation(context).email,
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            focusNode: emailFocusNode,
            decoration: InputDecoration(
              hintText: translation(context).typeHere,
            ),
            controller: emailController,
          )
        ],
      ),
    );
  }

  namePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          StatisticText(
            title: translation(context).whatIsYourName,
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: userNameController,
            focusNode: userNameFocusNode,
            decoration: InputDecoration(
              hintText: translation(context).typeHere,
            ),
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          StatisticText(
            title: translation(context).phoneNumber,
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: translation(context).typeHere,
            ),
            controller: phoneNumberController,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  passwordPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          StatisticText(
            title: authFormType == AuthFormType.signUp
                ? translation(context).setAPassword
                : translation(context).enterYourPassword,
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            focusNode: passwordFocusNode,
            controller: passwordController,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 14,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  !visible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      visible = !visible;
                    });
                  }
                },
              ),
              hintText: translation(context).password,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0)),
              contentPadding: EdgeInsets.all(10),
            ),
            obscureText: !visible,
          ),
          if (authFormType == AuthFormType.signUp)
            CustomSizedBox(
              sbSize: SBSize.smallest,
              height: true,
            ),
          if (authFormType == AuthFormType.signUp)
            TextFormField(
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: 14,
              ),
              controller: confirmPasswordController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    !visible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        visible = !visible;
                      });
                    }
                  },
                ),
                hintText: translation(context).confirmPassword,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0)),
                contentPadding: EdgeInsets.all(10),
              ),
              obscureText: !visible,
            ),
          SizedBox(
            height: 20,
          ),
          if (authFormType == AuthFormType.signIn)
            Center(
              child: OutlinedButton(
                onPressed: () async {
                  bool good = await UIServices().showDatSheet(
                    ForgotPasswordBottomSheet(
                      email: emailController.text.trim(),
                    ),
                    true,
                    context,
                  );

                  if (good == true) {
                    setState(
                      () {
                        _warning = translation(context).resetEmailSent;
                      },
                    );
                  }
                },
                child: Text(
                  translation(context).forgotPassword,
                ),
              ),
            ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  signUp() async {
    final auth = AuthProvider.of(context).auth;

    await auth
        .createUserWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text.trim(),
      userNameController.text.trim(),
    )
        .then((value) async {
      String token = await FirebaseMessaging.instance.getToken();

      StorageServices().createNewUser(
        userName: userNameController.text.trim(),
        images: [],
        phoneNumber: phoneNumberController.text.trim(),
        token: token,
        uid: value,
        email: emailController.text.trim(),
        university: university,
      );

      AuthProvider.of(context).auth.startVerifyingEmail();

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        CommunicationServices().showToast(
          translation(context).giveUsNotificationPermissions,
          Colors.red,
        );
      }

      Navigator.of(context).pop();

      showDialog(
          context: context,
          builder: (context) {
            return CustomDialogBox(
              bodyText: translation(context).weSentYouAnEmailToVerify,
              buttonText: translation(context).proceed,
              onButtonTap: () {
                AuthProvider.of(context).auth.reloadAccount(context);

                Navigator.of(context).pop();
              },
              showOtherButton: true,
            );
          });

      CommunicationServices().showToast(
        translation(context).successfullySignedIn,
        primaryColor,
      );

      widget.doAfterWards(value);
    }).timeout(
            Duration(
              seconds: 10,
            ), onTimeout: () {
      handleError(
        translation(context).errorLogginIn,
      );
    }).catchError((v) {
      handleError(
        v.toString(),
      );
    });
  }

  handleError(dynamic error) {
    processing = false;

    if (mounted) {
      setState(() {
        bgColor = Colors.red;
        _warning = error.toString();
      });
    }
  }

  signIn() async {
    final auth = AuthProvider.of(context).auth;

    await auth
        .signInWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text.trim(),
    )
        .then((value) async {
      FirebaseMessaging.instance.getToken().then(
        (token) {
          StorageServices().updateFCMToken(
            value,
            token,
          );
        },
      );

      StorageServices().notifyAboutLogin(value);

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        CommunicationServices().showToast(
          translation(context).giveUsNotificationPermissions,
          Colors.red,
        );
      }

      Navigator.of(context).pop();

      CommunicationServices().showToast(
        translation(context).successfullySignedIn,
        primaryColor,
      );

      widget.doAfterWards(value);
    }).timeout(
            Duration(
              seconds: 10,
            ), onTimeout: () {
      handleError(
        translation(context).errorLogginIn,
      );
    }).catchError((v) {
      handleError(
        v.toString(),
      );
    });
  }
}

class UIServices {
  showPopUpPushNotification(
    PushNotification notification,
    BuildContext context,
  ) {
    showSimpleNotification(
      Text(notification.title),
      leading: GestureDetector(
        onTap: () {
          StorageServices().handleClick(
            notification.thingType,
            notification.thingID,
            context,
          );
        },
        child: CircleAvatar(
          backgroundImage: notification.image == null
              ? AssetImage(
                  dorxLogo,
                )
              : NetworkImage(
                  notification.image,
                ),
        ),
      ),
      subtitle: GestureDetector(
        onTap: () {
          StorageServices().handleClick(
            notification.thingType,
            notification.thingID,
            context,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            notification.body,
          ),
        ),
      ),
      slideDismissDirection: DismissDirection.horizontal,
      background: primaryColor,
      duration: Duration(
        seconds: 10,
      ),
    );
  }

  Future<dynamic> showDatSheet(
    Widget sheet,
    bool willThisThingNeedScrolling,
    BuildContext context, {
    double height,
    bool enableDrag = true,
    bool useFramework = true,
    Function onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      enableDrag: enableDrag,
      isScrollControlled: willThisThingNeedScrolling,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: height ?? MediaQuery.of(context).size.height * 0.9,
          child: useFramework
              ? StatefulBuilder(builder: (context, setIt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (onClose != null) {
                            onClose();
                          }

                          if (context.canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).canvasColor,
                          child: Icon(
                            Icons.close,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              16,
                            ),
                            topRight: Radius.circular(
                              16,
                            ),
                          ),
                          child: Container(
                            color: Theme.of(context).canvasColor,
                            child: sheet,
                          ),
                        ),
                      )
                    ],
                  );
                })
              : sheet,
        );
      },
    );
  }

  ImageProvider<Object> getImageProvider(
    dynamic asset,
  ) {
    return asset == null
        ? null
        : asset is File
            ? FileImage(asset)
            : asset.toString().trim().contains(
                      "assets/images",
                    )
                ? AssetImage(
                    asset,
                  )
                : NetworkImage(
                    asset,
                  );
  }

  DecorationImage decorationImage(
    dynamic asset,
    bool darken,
  ) {
    return asset == null
        ? null
        : DecorationImage(
            image: getImageProvider(asset),
            fit: BoxFit.cover,
            colorFilter: darken
                ? ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  )
                : null,
          );
  }

  showLoginSheet(
    Function(String id) doAfterWards,
    BuildContext context,
  ) {
    showDatSheet(
      NewLoginSheet(
        doAfterWards: doAfterWards,
      ),
      true,
      context,
    );
  }
}

class MySliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  MySliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(MySliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class ForgotPasswordBottomSheet extends StatefulWidget {
  final String email;
  const ForgotPasswordBottomSheet({
    Key key,
    @required this.email,
  }) : super(key: key);

  @override
  State<ForgotPasswordBottomSheet> createState() =>
      _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  TextEditingController emailController = TextEditingController();
  bool processing = false;

  @override
  void initState() {
    emailController = TextEditingController(
      text: widget.email,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyKeyboardListenerWidget(
        proceed: () {
          proceed();
        },
        child: Column(
          children: [
            BackBar(
              text: "Forgot password",
              icon: null,
              onPressed: null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      StatisticText(
                        title: "Please enter your email",
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: emailController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ProceedButton(
              processing: processing,
              onTap: () {
                proceed();
              },
              text: "Press here to reset password",
            )
          ],
        ),
      ),
    );
  }

  proceed() async {
    if (emailController.text.trim().isEmpty) {
      CommunicationServices().showToast(
        "Please provide the email",
        Colors.red,
      );
    } else {
      setState(() {
        processing = true;
      });

      await AuthProvider.of(context)
          .auth
          .sendPasswordResetEmail(emailController.text.trim());

      Navigator.of(context).pop(true);
    }
  }
}
