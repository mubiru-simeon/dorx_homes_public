import 'package:cloud_firestore/cloud_firestore.dart';

class Vicinity {
  static const DIRECTORY = "vicinities";

  static const LAT = "lat";
  static const DATE = "date";
  static const LONG = "long";
  static const JSONDATA = "jsonData";
  static const IMAGES = "images";
  static const NAME = "name";
  static const VICINITY = "vicinity";

  dynamic _lat;
  dynamic _long;
  List _images;
  String _name;
  String _address;
  dynamic _data;

  dynamic get lat => _lat;
  String get name => _name;
  List get images => _images;
  dynamic get data => _data;
  String get address => _address;
  dynamic get long => _long;

  Vicinity.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _lat = pp[LAT];
    _images = pp[IMAGES] ?? [];
    _data = pp[JSONDATA] ?? {};
    _name = _data[NAME] ?? "Secret place =)";
    _address = _data[VICINITY] ?? "Near you";
    _long = pp[LONG];
  }
}
