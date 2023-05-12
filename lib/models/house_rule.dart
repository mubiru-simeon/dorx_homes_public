import 'package:cloud_firestore/cloud_firestore.dart';

class HouseRules {
  static const DIRECTORY = "houseRules";

  static const NAME = "name";
  static const PROHIBITED = "prohibited";
  static const DATE = "date";

  static const HOUSERULES = "houseRules";
  static const ADDITIONALRULES = "additionalRules";

  String _name;
  int _date;
  bool _prohibited;

  String get name => _name;
  int get date => _date;
  bool get prohibited => _prohibited;

  HouseRules.fromMap(String name, bool prohibited) {
    _prohibited = prohibited;
    _name = name;
  }

  HouseRules.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _name = pp[NAME];
    _date = pp[DATE];
  }
}
