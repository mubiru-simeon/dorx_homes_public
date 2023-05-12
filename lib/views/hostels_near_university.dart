import 'package:dorx/models/property.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HostelsNearUniversity extends StatefulWidget {
  final String universityID;
  HostelsNearUniversity({
    Key key,
    @required this.universityID,
  }) : super(key: key);

  @override
  State<HostelsNearUniversity> createState() => _HostelsNearUniversityState();
}

class _HostelsNearUniversityState extends State<HostelsNearUniversity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Hostels Near This University",
          ),
          SingleSchool(
            school: null,
            onTap: null,
            selected: false,
            schoolID: widget.universityID,
          ),
          Expanded(
              child: PaginateFirestore(
            query: FirebaseFirestore.instance
                .collection(Property.DIRECTORY)
                .where(
                  Property.AVAILABLE,
                  isEqualTo: true,
                )
                .where(
                  Property.NEARBYUNIVERSITY,
                  isEqualTo: widget.universityID,
                ),
            isLive: true,
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              Property property = Property.fromSnapshot(snapshot[index]);

              return SingleProperty(
                property: property,
                selectable: false,
                list: true,
                propertyID: property.id,
                selected: false,
                onTap: null,
              );
            },
            itemBuilderType: PaginateBuilderType.listView,
          ))
        ],
      ),
    );
  }
}
