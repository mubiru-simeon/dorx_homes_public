import 'package:cloud_firestore/cloud_firestore.dart';

class MassSuggestion {
  static const DIRECTORY = "massSuggestions";

  static const THINGID = "thingID";
  static const THINGTYPE = "thingType";
  static const TITLE = "title";
  static const TIME = "time";
  static const BODY = "body";
  static const CATEGORY = "category";
  static const IMAGES = "images";

  String _title;
  String _thingType;
  List _images;
  String _body;
  String _id;
  int _date;
  String _category;
  String _thingID;

  String get title => _title;
  String get thingType => _thingType;
  int get date => _date;
  String get category => _category;
  String get id => _id;
  String get body => _body;
  String get thingID => _thingID;
  List get images => _images;

  MassSuggestion.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _images = pp[IMAGES];
    _thingID = pp[THINGID];
    _category = pp[CATEGORY];
    _thingType = pp[THINGTYPE];
    _title = pp[TITLE];
    _category = pp[CATEGORY];
    _body = pp[BODY];
  }
}
