import 'package:dorx/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class UserProfileView extends StatefulWidget {
  final UserModel user;
  final String uid;
  UserProfileView({
    Key key,
    @required this.user,
    @required this.uid,
  }) : super(key: key);

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(UserModel.DIRECTORY)
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingWidget();
          } else {
            UserModel model = UserModel.fromSnapshot(
              snapshot.data,
            );

            return body(model);
          }
        },
      ),
    );
  }

  body(UserModel userModel) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              BackBar(
                icon: null,
                onPressed: null,
                text: "Profile",
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          userModel.profilePic != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    userModel.profilePic,
                                    width: kIsWeb
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.5,
                                    height: kIsWeb
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.5,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, v, b) {
                                      return Image(
                                        width: kIsWeb
                                            ? 100
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                        height: kIsWeb
                                            ? 100
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                        image: AssetImage(
                                          defaultUserPic,
                                        ),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image(
                                    width: kIsWeb
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.5,
                                    height: kIsWeb
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.5,
                                    image: AssetImage(defaultUserPic),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Material(
                          elevation: standardElevation,
                          borderRadius: standardBorderRadius,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(children: [
                              titleAndSub(
                                context,
                                title: "Username",
                                sub: userModel.userName,
                                showSpace: true,
                                visible: userModel.userName != null,
                              ),
                              if (userModel.phoneNumber != null &&
                                  userModel.phoneNumber.trim().isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    StorageServices().launchTheThing(
                                      "tel:${userModel.phoneNumber}",
                                    );
                                  },
                                  child: titleAndSub(
                                    context,
                                    title: "Phone Number (tap here to call)",
                                    sub: userModel.phoneNumber,
                                    showSpace: true,
                                    clickable: true,
                                    visible: userModel.phoneNumber != null,
                                  ),
                                ),
                              SizedBox(
                                height: 20,
                              ),
                              if (userModel.adder != null) CustomDivider(),
                              if (userModel.adder != null)
                                SizedBox(
                                  height: 20,
                                ),
                            ]),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  titleAndSub(
    BuildContext context, {
    String title,
    String sub,
    bool clickable,
    bool showSpace,
    bool visible,
  }) {
    return Visibility(
      visible: visible,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    sub,
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          clickable != null && clickable ? Colors.blue : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: showSpace,
            child: SizedBox(
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
