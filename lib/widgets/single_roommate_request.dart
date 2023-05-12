import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../../../models/roommate_request.dart';
import '../../../models/thing_type.dart';
import '../views/views.dart';

class SingleRoommateRequest extends StatefulWidget {
  final String requestID;
  final RoommateRequest request;
  final bool horizontal;
  final bool simple;
  SingleRoommateRequest({
    Key key,
    @required this.request,
    this.horizontal = false,
    this.simple = true,
    @required this.requestID,
  }) : super(key: key);

  @override
  State<SingleRoommateRequest> createState() => _SingleRoommateRequestState();
}

class _SingleRoommateRequestState extends State<SingleRoommateRequest> {
  @override
  Widget build(BuildContext context) {
    return widget.request == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(RoommateRequest.DIRECTORY)
                .doc(widget.requestID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "Property",
                    thingID: widget.requestID,
                  );
                } else {
                  RoommateRequest model = RoommateRequest.fromSnapshot(
                    snapshot.data,
                  );

                  return body(model);
                }
              } else {
                return LoadingWidget();
              }
            })
        : body(widget.request);
  }

  body(RoommateRequest request) {
    return Container(
      width: widget.horizontal ? MediaQuery.of(context).size.width * 0.7 : null,
      padding: EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 3,
      ),
      child: Column(
        children: [
          widget.horizontal
              ? Expanded(
                  child: bb(request),
                )
              : bb(request),
          OnlyWhenLoggedIn(
              notSignedIn: SizedBox(),
              signedInBuilder: (uid) {
                if (uid == request.requester) {
                  return Row(
                    children: [
                      Expanded(
                        child: SingleBigButton(
                          text: "Edit",
                          color: Colors.green,
                          onPressed: () {
                            UIServices().showDatSheet(
                              RequestARoommateBottomSheet(
                                request: request,
                              ),
                              true,
                              context,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: SingleBigButton(
                          text: "Delete",
                          color: Colors.red,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomDialogBox(
                                  bodyText:
                                      "Do you really want to delete this request?",
                                  buttonText: "YYep. Do it",
                                  onButtonTap: () {
                                    FirebaseFirestore.instance
                                        .collection(RoommateRequest.DIRECTORY)
                                        .doc(request.id)
                                        .delete();

                                    CommunicationServices().showToast(
                                      "Successfully deleted your request. Thank you for using $capitalizedAppName",
                                      Colors.green,
                                    );
                                  },
                                  showOtherButton: true,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return SizedBox();
                }
              })
        ],
      ),
    );
  }

  bb(RoommateRequest request) {
    return GestureDetector(
      onTap: () {
        UIServices().showDatSheet(
          RoomRequestDetailsBottomSheet(
            request: request,
          ),
          true,
          context,
        );
      },
      child: Material(
        elevation: !widget.simple ? 0 : standardElevation,
        borderRadius: standardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FavoriteButton(
                    thingType: ThingType.ROOMMATEREQUEST,
                    thingID: widget.requestID,
                  ),
                ],
              ),
              Text(
                "${request.name}, ${request.seekerGender}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Seeking a ${request.seekeeGender} roommate",
              ),
              SizedBox(
                height: 10,
              ),
              if (request.details != null &&
                  request.details.toString().trim().isNotEmpty)
                Text(
                  "About ${request.name}: ${request.details}",
                  maxLines: !widget.simple ? 20 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (request.details != null &&
                  request.details.toString().trim().isNotEmpty)
                SizedBox(
                  height: 10,
                ),
              Text(
                request.text,
                maxLines: !widget.simple ? 20 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 10,
              ),
              if (request.rules != null &&
                  request.rules.toString().trim().isNotEmpty &&
                  !widget.simple)
                Text(
                  "My Conditions: ${request.rules}",
                ),
              if (request.rules != null &&
                  request.rules.toString().trim().isNotEmpty &&
                  !widget.simple)
                SizedBox(
                  height: 10,
                ),
              GestureDetector(
                onTap: () {
                  StorageServices().launchTheThing(
                    "tel:${request.phoneNumber}",
                  );
                },
                child: Text(
                  "Phone Number: ${request.phoneNumber}\nTap here to call",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateService().getCoolTime(request.time),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomRequestDetailsBottomSheet extends StatefulWidget {
  final RoommateRequest request;
  RoomRequestDetailsBottomSheet({
    Key key,
    @required this.request,
  }) : super(key: key);

  @override
  State<RoomRequestDetailsBottomSheet> createState() =>
      _RoomRequestDetailsBottomSheetState();
}

class _RoomRequestDetailsBottomSheetState
    extends State<RoomRequestDetailsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Room Request",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: SingleRoommateRequest(
                request: widget.request,
                simple: false,
                requestID: widget.request.id,
              ),
            ),
          ),
        )
      ],
    );
  }
}
