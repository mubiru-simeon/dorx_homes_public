import 'package:cloud_firestore/cloud_firestore.dart';

class SavedItem {
  static const DIRECTORY = "savedDirectory";

  static const TYPE = "type";
  static const TIME = "time";
  static const OWNER = "owner";
  static const COUNT = "count";

  String _id;
  String _type;

  String get id => _id;
  String get type => _type;

  SavedItem.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _type = pp[TYPE];
  }
}
