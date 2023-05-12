import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class AllRoommateRequests extends StatefulWidget {
  AllRoommateRequests({Key key}) : super(key: key);

  @override
  State<AllRoommateRequests> createState() => _AllRoommateRequestsState();
}

class _AllRoommateRequestsState extends State<AllRoommateRequests>
    with TickerProviderStateMixin {
  TabController tabController;
  List pages;

  @override
  void initState() {
    pages = [
      "requests",
      "my requests",
    ];

    tabController = TabController(
      vsync: this,
      length: pages.length,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (hj, jh) {
          return [
            CustomSliverAppBar(
              title: "Roommate Requests",
              backEnabled: true,
            ),
            SliverPersistentHeader(
              delegate: MySliverAppBarDelegate(
                TabBar(
                  labelColor: getTabColor(context, true),
                  unselectedLabelColor: getTabColor(context, false),
                  controller: tabController,
                  isScrollable: true,
                  tabs: pages
                      .map(
                        (e) => Tab(
                          text: e.toString().toUpperCase(),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: pages
              .map(
                (e) => SingleRequestsView(
                  mode: e,
                ),
              )
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          UIServices().showDatSheet(
            RequestARoommateBottomSheet(
              request: null,
            ),
            true,
            context,
          );
        },
        icon: Icon(Icons.add),
        label: Text(
          "Find A Roommate",
        ),
      ),
    );
  }
}

class SingleRequestsView extends StatefulWidget {
  final String mode;
  SingleRequestsView({
    Key key,
    @required this.mode,
  }) : super(key: key);

  @override
  State<SingleRequestsView> createState() => _SingleRequestsViewState();
}

class _SingleRequestsViewState extends State<SingleRequestsView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.mode == "my requests"
        ? OnlyWhenLoggedIn(
            signedInBuilder: (uid) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: PaginateFirestore(
                  isLive: true,
                  itemsPerPage: 3,
                  onEmpty: NoDataFound(
                    text: "No Requests Yet",
                  ),
                  itemBuilder: (context, snapshot, index) {
                    RoommateRequest roommateRequest =
                        RoommateRequest.fromSnapshot(snapshot[index]);

                    return SingleRoommateRequest(
                      request: roommateRequest,
                      simple: true,
                      requestID: roommateRequest.id,
                    );
                  },
                  query: FirebaseFirestore.instance
                      .collection(RoommateRequest.DIRECTORY)
                      .where(RoommateRequest.REQUESTER, isEqualTo: uid)
                      .orderBy(RoommateRequest.TIME, descending: true),
                  itemBuilderType: PaginateBuilderType.listView,
                ),
              );
            },
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: PaginateFirestore(
              isLive: true,
              itemsPerPage: 3,
              onEmpty: NoDataFound(
                text: "No Requests Yet",
              ),
              itemBuilder: (context, snapshot, index) {
                RoommateRequest roommateRequest =
                    RoommateRequest.fromSnapshot(snapshot[index]);

                return SingleRoommateRequest(
                  request: roommateRequest,
                  requestID: roommateRequest.id,
                  simple: true,
                );
              },
              query: FirebaseFirestore.instance
                  .collection(RoommateRequest.DIRECTORY),
              itemBuilderType: PaginateBuilderType.listView,
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class RequestARoommateBottomSheet extends StatefulWidget {
  final RoommateRequest request;
  RequestARoommateBottomSheet({
    Key key,
    @required this.request,
  }) : super(key: key);

  @override
  State<RequestARoommateBottomSheet> createState() =>
      _RequestARoommateBottomSheetState();
}

class _RequestARoommateBottomSheetState
    extends State<RequestARoommateBottomSheet> {
  bool processing = false;
  String seekerGender = "female";
  String seekeeGender = "female";
  TextEditingController textController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController academicsController = TextEditingController();
  TextEditingController rulesController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.request != null) {
      seekerGender = widget.request.seekerGender;
      seekeeGender = widget.request.seekeeGender;
      textController = TextEditingController(text: widget.request.text);
      nameController = TextEditingController(text: widget.request.name);
      academicsController = TextEditingController(text: widget.request.details);
      rulesController = TextEditingController(text: widget.request.rules);
      phoneNumberController =
          TextEditingController(text: widget.request.phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Seeking A Roommate",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InformationalBox(
                      visible: true,
                      onClose: null,
                      message:
                          "This feature was designed to help you if you're failing to find a roommate for your hostel room. Instead of littering our hostel room with hastily printed posters, you can post your request here and it shall be seen by thousands of potential roomies.",
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Your name",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: phoneNumberController,
                      maxLines: 1,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Your phone number",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: academicsController,
                      decoration: InputDecoration(
                        hintText: "[OPTIONAL] Your University, course and year",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: textController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "Who are you looking for?",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "I am a",
                    ),
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                            child: RowSelector(
                              text: "Female",
                              selected: seekerGender == "female",
                              onTap: () {
                                setState(() {
                                  seekerGender = "female";
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RowSelector(
                              text: "Male",
                              selected: seekerGender == "male",
                              onTap: () {
                                setState(() {
                                  seekerGender = "male";
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "I'm looking for a",
                    ),
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                            child: RowSelector(
                              text: "Female",
                              selected: seekeeGender == "female",
                              onTap: () {
                                setState(() {
                                  seekeeGender = "female";
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RowSelector(
                              text: "Male",
                              selected: seekeeGender == "male",
                              onTap: () {
                                setState(() {
                                  seekeeGender = "male";
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      maxLines: 4,
                      controller: rulesController,
                      decoration: InputDecoration(
                        hintText: "Any House Rules?",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Wrap(children: [
        ProceedButton(
          processing: processing,
          onTap: () {
            if (phoneNumberController.text.trim().isEmpty ||
                phoneNumberController.text.trim().length < 10) {
              CommunicationServices().showToast(
                "Please provide your valid phone number.",
                Colors.red,
              );
            } else {
              if (textController.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "Please tell us who you're looking for.",
                  Colors.red,
                );
              } else {
                if (nameController.text.trim().isEmpty) {
                  CommunicationServices().showToast(
                    "Please enter your name.",
                    Colors.red,
                  );
                } else {
                  if (!AuthProvider.of(context).auth.isSignedIn()) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return NotLoggedInDialogBox(
                          onLoggedIn: () {
                            doIt();
                          },
                        );
                      },
                    );
                  } else {
                    doIt();
                  }
                }
              }
            }
          },
          text: "Finish",
        )
      ]),
    );
  }

  doIt() {
    setState(() {
      processing = true;
    });

    if (widget.request == null) {
      FirebaseFirestore.instance.collection(RoommateRequest.DIRECTORY).add({
        RoommateRequest.TIME: DateTime.now().millisecondsSinceEpoch,
        RoommateRequest.MATCHED: false,
        RoommateRequest.REQUESTER:
            AuthProvider.of(context).auth.getCurrentUID(),
        RoommateRequest.TEXT: textController.text.trim(),
        RoommateRequest.SEEKERGENDER: seekerGender,
        RoommateRequest.SEEKERDETAILS: academicsController.text.trim(),
        RoommateRequest.SEEKERNAME: nameController.text.trim(),
        RoommateRequest.SEEKEEGENDER: seekeeGender,
        RoommateRequest.ROOMRULES: rulesController.text.trim(),
        RoommateRequest.PHONENUMBER: phoneNumberController.text.trim(),
      }).then((value) {
        if (context.canPop()) {
          Navigator.of(context).pop();
        } else {
          context.pushReplacementNamed(RouteConstants.home);
        }

        CommunicationServices().showToast(
          "Your request has been successfully placed.",
          Colors.green,
        );
      });
    } else {
      FirebaseFirestore.instance
          .collection(RoommateRequest.DIRECTORY)
          .doc(widget.request.id)
          .update({
        RoommateRequest.TIME: DateTime.now().millisecondsSinceEpoch,
        RoommateRequest.MATCHED: false,
        RoommateRequest.REQUESTER:
            AuthProvider.of(context).auth.getCurrentUID(),
        RoommateRequest.TEXT: textController.text.trim(),
        RoommateRequest.SEEKERGENDER: seekerGender,
        RoommateRequest.SEEKERDETAILS: academicsController.text.trim(),
        RoommateRequest.SEEKERNAME: nameController.text.trim(),
        RoommateRequest.SEEKEEGENDER: seekeeGender,
        RoommateRequest.ROOMRULES: rulesController.text.trim(),
        RoommateRequest.PHONENUMBER: phoneNumberController.text.trim(),
      }).then((value) {
        if (context.canPop()) {
          Navigator.of(context).pop();
        } else {
          context.pushReplacementNamed(RouteConstants.home);
        }

        CommunicationServices().showToast(
          "Your request has been successfully updated.",
          Colors.green,
        );
      });
    }
  }
}
