import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'no_data_found_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Notifications",
          ),
          Expanded(
            child: OnlyWhenLoggedIn(
              doOnceSignedIn: () {
                FirebaseDatabase.instance
                    .ref()
                    .child(NotificationModel.NOTIFICATIONCOUNT)
                    .child(AuthProvider.of(context).auth.getCurrentUID())
                    .remove();
              },
              signedInBuilder: (uid) {
                return PaginateFirestore(
                  onEmpty: NoDataFound(
                    text: "No Notifications Yet",
                  ),
                  itemsPerPage: 4,
                  itemBuilder: (
                    context,
                    snapshot,
                    index,
                  ) {
                    NotificationModel notificationModel =
                        NotificationModel.fromSnapshot(
                      snapshot[index],
                      context,
                    );

                    return SingleNotification(
                      notification: notificationModel,
                    );
                  },
                  isLive: true,
                  query: FirebaseFirestore.instance
                      .collection(NotificationModel.DIRECTORY)
                      .doc(uid)
                      .collection(uid)
                      .orderBy(
                        NotificationModel.TIME,
                        descending: true,
                      ),
                  itemBuilderType: PaginateBuilderType.listView,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
