import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../models/user_feedback.dart';
import '../services/services.dart';
import 'widgets.dart';

class FeedbackOptionsBottomSheet extends StatefulWidget {
  final String additionalInfo;
  FeedbackOptionsBottomSheet({
    Key key,
    @required this.additionalInfo,
  }) : super(key: key);

  @override
  State<FeedbackOptionsBottomSheet> createState() =>
      _FeedbackOptionsBottomSheetState();
}

class _FeedbackOptionsBottomSheetState
    extends State<FeedbackOptionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigoAccent,
                primaryColor,
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                "Ola.. (that's Hi in Portuguese btw)",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "At $capitalizedAppName, we treasure your opinion and we always look forward to hearing from you. What would you like to do?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.REPORT,
                      ),
                      true,
                      context,
                    );
                    /*  BetterFeedback.of(context).show((p) {
                      handleFeedback(
                        p,
                        UserFeedback.REPORT,
                      );
                    }); */
                  },
                  selected: false,
                  asset: null,
                  text: "Report something in the app",
                  desc:
                      "An offensive post, a fraudster or even a typing error.",
                  icon: Icon(Icons.warning),
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.BUG,
                      ),
                      true,
                      context,
                    );

                    /*  BetterFeedback.of(context).show((p0) {
                      handleFeedback(
                        p0,
                        UserFeedback.BUG,
                      );
                    }); */
                  },
                  selected: false,
                  asset: null,
                  text: "Report an Error with the app",
                  icon: Icon(FontAwesomeIcons.spider),
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                   Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.FEATURE,
                      ),
                      true,
                      context,
                    );
                  },
                  selected: false,
                  asset: null,
                  text: "Suggest a Feature",
                  icon: Icon(Icons.new_releases),
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                   Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.LIKES,
                      ),
                      true,
                      context,
                    );
                    /*  BetterFeedback.of(context).show((p0) {
                      handleFeedback(
                        p0,
                        UserFeedback.LIKES,
                      );
                    }); */
                  },
                  selected: false,
                  asset: null,
                  text: "Tell us what you like",
                  icon: Icon(FontAwesomeIcons.thumbsUp),
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.DISLIKES,
                      ),
                      true,
                      context,
                    );
                    /*  BetterFeedback.of(context).show((p0) {
                      handleFeedback(
                        p0,
                        UserFeedback.DISLIKES,
                      );
                    }); */
                  },
                  selected: false,
                  asset: null,
                  text: "Tell us what you don't like",
                  icon: Icon(FontAwesomeIcons.thumbsDown),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  handleFeedback(
    UserFeedback feedback,
    String category,
  ) async {
    CommunicationServices().showToast(
      "Thank you. your feedback has been received. if need be, we shall contact you shortly for further details.",
      Colors.green,
    );

    List imgs = await ImageServices().uploadImages(
      path: "feedback_images",
      onError: () {},
      images: [],
      bytes: feedback.screenshot,
    );

    FirebaseFirestore.instance.collection(UserFeedback.DIRECTORY).add({
      UserFeedback.ADDITIONALINFO: widget.additionalInfo,
      UserFeedback.APPVERSION: versionNumber,
      UserFeedback.PENDING: true,
      UserFeedback.IMAGES: imgs,
      UserFeedback.CATEGORY: category,
      UserFeedback.TEXT: feedback.text,
      UserFeedback.ATTACHEDDATA: feedback.extra,
      UserFeedback.DATE: DateTime.now().millisecondsSinceEpoch,
      UserFeedback.SENDER: AuthProvider.of(context).auth.isSignedIn()
          ? AuthProvider.of(context).auth.getCurrentUID()
          : null,
    });
  }
}

class OnlyTextBottomSheet extends StatefulWidget {
  final String category;
  OnlyTextBottomSheet({
    Key key,
    @required this.category,
  }) : super(key: key);

  @override
  State<OnlyTextBottomSheet> createState() => _OnlyTextBottomSheetState();
}

class _OnlyTextBottomSheetState extends State<OnlyTextBottomSheet> {
  TextEditingController feedbackController = TextEditingController();
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Anhaaa.. We're all ears.",
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                InformationalBox(
                  visible: true,
                  onClose: null,
                  message: "What's on your mind? Give us the gory details.",
                ),
                TextField(
                  maxLines: null,
                  controller: feedbackController,
                  decoration: InputDecoration(
                    hintText: "Type here",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Wrap(children: [
        ProceedButton(
          text: "Proceed",
          processing: processing,
          onTap: () async {
            if (feedbackController.text.trim().isEmpty) {
              CommunicationServices().showToast(
                "Please enter your suggestion",
                Colors.red,
              );
            } else {
              setState(() {
                processing = true;
              });

              CommunicationServices().showToast(
                "Thank you. your feedback has been received. if need be, we shall contact you shortly for further details.",
                Colors.green,
              );

              Navigator.of(context).pop();

              FirebaseFirestore.instance.collection(UserFeedback.DIRECTORY).add(
                {
                  UserFeedback.APPVERSION: versionNumber,
                  UserFeedback.PENDING: true,
                  UserFeedback.CATEGORY: widget.category,
                  UserFeedback.TEXT: feedbackController.text.trim(),
                  UserFeedback.DATE: DateTime.now().millisecondsSinceEpoch,
                  UserFeedback.SENDER:
                      AuthProvider.of(context).auth.isSignedIn()
                          ? AuthProvider.of(context).auth.getCurrentUID()
                          : null,
                },
              );
            }
          },
        )
      ]),
    );
  }
}
