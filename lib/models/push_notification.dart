import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification.dart';

class PushNotification {
  String _title;
  String _body;
  String _thingID;
  String _image;
  String _thingType;

  PushNotification.fromRemoteMessage(RemoteMessage initialMessage) {
    _title = initialMessage.notification?.title;
    _body = initialMessage.notification?.body;
    _image = initialMessage.notification.android.imageUrl;
    _thingType = initialMessage.data[NotificationModel.THINGTYPE];
    _thingID = initialMessage.data[NotificationModel.THINGID];
  }

  String get title => _title;
  String get image => _image;
  String get body => _body;
  String get thingType => _thingType;
  String get thingID => _thingID;
}
