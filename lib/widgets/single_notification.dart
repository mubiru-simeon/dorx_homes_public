import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/notification.dart';
import '../services/storage_service.dart';

class SingleNotification extends StatefulWidget {
  final NotificationModel notification;
  SingleNotification({
    Key key,
    @required this.notification,
  }) : super(key: key);

  @override
  State<SingleNotification> createState() => _SingleNotificationState();
}

class _SingleNotificationState extends State<SingleNotification> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: GestureDetector(
        onTap: () {
          StorageServices().handleClick(
            widget.notification.thingType,
            widget.notification.primaryId,
            context,
          );
        },
        child: Material(
          elevation: standardElevation,
          borderRadius: standardBorderRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notification.title ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      widget.notification.body ?? "",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "TAP HERE TO VIEW DETAILS",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.notification.time != null)
                              Text(
                                DateFormat("d/MM/y").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    widget.notification.time,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  //      color: Theme.of(context)
                                  //           .primaryColorDark
                                  //           .withOpacity(0.5),
                                ),
                              ),
                            if (widget.notification.time != null)
                              Text(
                                DateFormat("HH:mm").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    widget.notification.time,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  //      color: Theme.of(context)
                                  //           .primaryColorDark
                                  //           .withOpacity(0.5),
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
