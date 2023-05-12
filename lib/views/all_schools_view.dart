import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class AllSchoolsView extends StatefulWidget {
  AllSchoolsView({
    Key key,
  }) : super(key: key);

  @override
  State<AllSchoolsView> createState() => _AllSchoolsViewState();
}

class _AllSchoolsViewState extends State<AllSchoolsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Select Your University / School",
          ),
          Expanded(
            child: PaginateFirestore(
              isLive: true,
              itemBuilderType: PaginateBuilderType.listView,
              itemBuilder: (
                context,
                snapshot,
                index,
              ) {
                SchoolModel university =
                    SchoolModel.fromSnapshot(snapshot[index]);

                return SingleSchool(
                  school: university,
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.hostelsNearUniversity,
                      params: {
                        "id": university.id,
                      },
                    );
                  },
                  selected: false,
                  schoolID: university.id,
                );
              },
              query: FirebaseFirestore.instance
                  .collection(SchoolModel.DIRECTORY)
                  .orderBy(
                    SchoolModel.TIMEADDED,
                    descending: true,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
