import 'package:badges/badges.dart' as badges;
import 'package:dorx/services/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/notification.dart';
import 'loading_widget.dart';
import 'only_when_logged_in.dart';

class NotificationsButton extends StatelessWidget {
  final Color color;
  const NotificationsButton({
    Key key,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OnlyWhenLoggedIn(
        loadingView: GestureDetector(
          onTap: () {
            context.pushNamed(
              RouteConstants.notifications,
            );
          },
          child: Icon(
            Icons.notifications,
            color: color ?? Colors.grey,
          ),
        ),
        signedInBuilder: (uid) {
          return StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref()
                .child(NotificationModel.NOTIFICATIONCOUNT)
                .child(uid)
                .onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return LoadingWidget();
              } else {
                int count = snapshot.data.snapshot.value ?? 0;

                return badges.Badge(
                  showBadge: true,
                  badgeContent: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(
              RouteConstants.notifications,
            );
                    },
                    child: Icon(
                      Icons.notifications,
                      color: color ?? Colors.grey,
                    ),
                  ),
                );
              }
            },
          );
        },
        notSignedIn: GestureDetector(
          onTap: () {
            context.pushNamed(
              RouteConstants.notifications,
            );
          },
          child: Icon(
            Icons.notifications,
            color: color ?? Colors.grey,
          ),
        ),
      ),
    );
  }
}
