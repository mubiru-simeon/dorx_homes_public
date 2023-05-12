import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  static const DIRECTORY = "notifications";
  static const NOTIFICATIONCOUNT = "notificationCount";

  static const TIME = "time";
  static const THINGID = "thingID";
  static const TITLE = "title";
  static const BODY = "body";
  static const THINGTYPE = "thingType";
  static const SENDER = "sender";

  int _time;
  String _notificationId;
  String _recepient;
  String _thingId;
  String _thingtype;
  String _body;
  String _title;

  int get time => _time;
  String get notificationId => _notificationId;
  String get thingType => _thingtype;
  String get primaryId => _thingId;
  String get title => _title;
  String get recepient => _recepient;
  String get body => _body;

  NotificationModel.fromSnapshot(
    DocumentSnapshot snapshot,
    BuildContext context,
  ) {
    Map pp = snapshot.data() as Map;

    _title = pp[TITLE] ?? "";
    _body = pp[BODY] ?? "";
    _time = pp[TIME];
    _thingId = pp[THINGID];
    _notificationId = snapshot.id;
    _thingtype = pp[THINGTYPE];
  }

  NotificationModel.fromData(
    String receiver,
    String title,
    String body,
    DateTime time,
  ) {
    _recepient = receiver;
    _title = title;
    _body = body;
    _time = time.millisecondsSinceEpoch;
  }
}
