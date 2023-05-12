import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class SavedView extends StatefulWidget {
  const SavedView({Key key}) : super(key: key);

  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            StatisticText(
              title: "Saved Homes",
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: OnlyWhenLoggedIn(
                signedInBuilder: (uid) {
                  return PaginateFirestore(
                    isLive: true,
                    itemBuilder: (context, snapshot, index) {
                      String id = snapshot[index].id;

                      return SingleProperty(
                        property: null,
                        selectable: false,
                        selected: false,
                        onTap: null,
                        propertyID: id,
                        horizontal: false,
                        list: true,
                      );
                    },
                    query: FirebaseFirestore.instance
                        .collection(SavedItem.DIRECTORY)
                        .doc(uid)
                        .collection(uid)
                        .where(
                          SavedItem.TYPE,
                          isEqualTo: ThingType.PROPERTY,
                        ),
                    itemBuilderType: PaginateBuilderType.listView,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
