import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RequestHallSpaceBottomSheet extends StatefulWidget {
  final bool requesting;
  RequestHallSpaceBottomSheet({
    Key key,
    @required this.requesting,
  }) : super(key: key);

  @override
  State<RequestHallSpaceBottomSheet> createState() =>
      _RequestHallSpaceBottomSheetState();
}

class _RequestHallSpaceBottomSheetState
    extends State<RequestHallSpaceBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "What's your gender?",
        ),
        InformationalBox(
          visible: true,
          onClose: null,
          message:
              "Most halls are only for a specific gender, so please tell us which gender is yours.",
        ),
        SingleSelectTile(
          onTap: () {
            if (context.canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pushReplacementNamed(RouteConstants.home);
            }

            UIServices().showDatSheet(
              SelectSchool(
                gender: "male",
                requesting: widget.requesting,
              ),
              true,
              context,
            );
          },
          selected: false,
          icon: Icon(FontAwesomeIcons.person),
          asset: null,
          text: "Male",
        ),
        SingleSelectTile(
          onTap: () {
            if (context.canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pushReplacementNamed(RouteConstants.home);
            }

            UIServices().showDatSheet(
              SelectSchool(
                gender: "female",
                requesting: widget.requesting,
              ),
              true,
              context,
            );
          },
          selected: false,
          icon: Icon(FontAwesomeIcons.personDress),
          asset: null,
          text: "Female",
        ),
      ],
    );
  }
}

class SelectSchool extends StatefulWidget {
  final bool requesting;
  final String gender;
  SelectSchool({
    Key key,
    @required this.requesting,
    @required this.gender,
  }) : super(key: key);

  @override
  State<SelectSchool> createState() => _SelectSchoolState();
}

class _SelectSchoolState extends State<SelectSchool> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Select a School",
        ),
        Expanded(
          child: PaginateFirestore(
            itemBuilder: (context, snapshot, index) {
              SchoolModel schoolModel =
                  SchoolModel.fromSnapshot(snapshot[index]);

              return SingleSchool(
                school: schoolModel,
                onTap: () {
                  if (AuthProvider.of(context).auth.isSignedIn()) {
                    doIt(schoolModel.id);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return NotLoggedInDialogBox(
                          onLoggedIn: () {
                            doIt(schoolModel.id);
                          },
                        );
                      },
                    );
                  }
                },
                selected: false,
                schoolID: schoolModel.id,
              );
            },
            query: FirebaseFirestore.instance.collection(SchoolModel.DIRECTORY),
            itemBuilderType: PaginateBuilderType.listView,
            isLive: true,
            itemsPerPage: 3,
          ),
        )
      ],
    );
  }

  doIt(String schoolID) {
    Navigator.of(context).pop();

    if (widget.requesting) {
      FirebaseFirestore.instance.collection(HallBedspaceRequest.DIRECTORY).add({
        HallBedspaceRequest.CUSTOMER:
            AuthProvider.of(context).auth.getCurrentUID(),
        HallBedspaceRequest.PENDING: true,
        HallBedspaceRequest.UNIVERSITY: schoolID,
        HallBedspaceRequest.COMPLETED: false,
        HallBedspaceRequest.DATE: DateTime.now().millisecondsSinceEpoch,
        HallBedspaceRequest.GENDER: widget.gender,
      }).then((value) {
        CommunicationServices().showToast(
          "Successfully placed a request. We will be in touch shortly.",
          Colors.green,
        );
      });
    } else {
      FirebaseFirestore.instance
          .collection(HallBedspaceRequest.IHAVEAROOM)
          .add({
        HallBedspaceRequest.CUSTOMER:
            AuthProvider.of(context).auth.getCurrentUID(),
        HallBedspaceRequest.PENDING: true,
        HallBedspaceRequest.UNIVERSITY: schoolID,
        HallBedspaceRequest.COMPLETED: false,
        HallBedspaceRequest.DATE: DateTime.now().millisecondsSinceEpoch,
        HallBedspaceRequest.GENDER: widget.gender,
      }).then((value) {
        CommunicationServices().showToast(
          "Successfully recorded. We will be in touch shortly.",
          Colors.green,
        );
      });
    }
  }
}
