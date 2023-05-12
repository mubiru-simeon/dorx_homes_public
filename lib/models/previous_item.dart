import 'package:cloud_firestore/cloud_firestore.dart';

class PreviousItem {
  static const TYPE = "type";
  static const THINGID = "thingID";
  static const DIRECTORY = "watchHistory";
  static const TIME = "time";

  String _id;
  String _type;
  String _thingID;

  String get id => _id;
  String get type => _type;
  String get thingID => _thingID;

  PreviousItem.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _type = pp[TYPE];
    _thingID =pp[THINGID];
  }
}
