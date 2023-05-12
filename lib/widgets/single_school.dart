import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import 'loading_widget.dart';

class SingleSchool extends StatelessWidget {
  final SchoolModel school;
  final String schoolID;
  final bool selected;
  final bool listHorizontal;
  final Function onTap;
  const SingleSchool({
    Key key,
    @required this.school,
    @required this.onTap,
    @required this.selected,
    this.listHorizontal,
    @required this.schoolID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return school == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(SchoolModel.DIRECTORY)
                .doc(schoolID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              } else {
                SchoolModel university = SchoolModel.fromSnapshot(
                  snapshot.data,
                );

                return body(university, context);
              }
            })
        : body(
            school,
            context,
          );
  }

  body(
    SchoolModel material,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        elevation: standardElevation,
        color: selected ? Colors.green : null,
        borderRadius: standardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListTile(
            onTap: () {
              if (onTap != null) {
                onTap();
              } else {}
            },
            leading: CircleAvatar(
              backgroundImage: material.image != null
                  ? UIServices().getImageProvider(
                      material.image,
                    )
                  : null,
              child: material.image == null ? Icon(Icons.school) : null,
            ),
            title: Text(
              material.name,
            ),
            subtitle: Text(
              material.motto ?? material.address,
            ),
          ),
        ),
      ),
    );
  }
}
