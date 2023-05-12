import 'package:cloud_firestore/cloud_firestore.dart';

class Amenity {
  static const DIRECTORY = "amenities";

  static const NAME = "name";
  static const CATEGORY = "category";
  static const IMAGE = "image";
  static const DATE = "date";
  static const ADDER = "adder";

  String _name;
  String _id;
  String _category;
  String _image;
  int _date;

  String get name => _name;
  String get category => _category;
  String get image => _image;
  String get id => _id;
  int get time => _date;

  Amenity.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _name = pp[NAME];
    _image = pp[IMAGE];
    _date = pp[DATE];
    _category = pp[CATEGORY] ?? WELLBEING;
  }
}

const SECURITY = "security";
const LUXURY = "luxury";
const WELLBEING = "wellbeing";

List<String> amenityTypes = [
  WELLBEING,
  LUXURY,
  SECURITY,
];
