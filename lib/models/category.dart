import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';

class EntityCategory {
  static const DIRECTORY = "entityCategories";

  static const IMAGE = "images";
  static const DESC = "details";
  static const THINGTYPE = "thingType";
  static const NAME = "name";
  static const DATE = "date";
  static const CATEGORYTYPE = "categoryType";
  static const ENTITY = "entity";

  String _name;
  String _desc;
  String _id;
  String _categoryType;
  String _thingType;
  List _image;
  int _date;

  String get name => _name;
  String get desc => _desc;
  String get categoryType => _categoryType;
  String get thingType => _thingType;
  List get image => _image;
  String get id => _id;
  int get date => _date;

  EntityCategory.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _desc = pp[DESC];
    _id = snapshot.id;
    _date = pp[DATE];
    _name = pp[NAME] ?? "";
    _categoryType = pp[CATEGORYTYPE] ?? Property.RESIDENTIAL;
    _thingType = pp[THINGTYPE] ?? ThingType.PROPERTY;
    _image = pp[IMAGE] ?? [];
  }
}
