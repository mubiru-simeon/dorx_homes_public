import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  static const DIRECTORY = "restaurants";
  static const IMAGES = "images";
  static const LAT = "lat";
  static const LONG = "long";
  static const NAME = "name";
  static const DESCRIPTION = "description";
  static const DISPLAYPIC = "displayPicture";
  static const STOREWALLPAPER = "wallPaper";
  static const OWNERS = "owners";
  static const FACEBOOKLINK = "facebookLink";
  static const TWITTERLINK = "twitterLink";
  static const INSTAGRAMLINK = "instagramLink";
  static const PHONENUMBER = "phoneNumber";
  static const EMAIL = "email";
  static const DATEOFCREATION = "time";

  String _id;
  String _name;
  String _description;
  String _wallPaper;
  String _facebookLink;
  String _twitterLink;
  String _instagramLink;
  String _displayPic;
  List _images;
  List _owner;

  String _phoneNumber;
  String _email;
  dynamic _lat;
  dynamic _long;

  String get phoneNumber => _phoneNumber;
  String get email => _email;
  List get images => _images;
  String get name => _name;
  String get id => _id;
  dynamic get lat => _lat;
  dynamic get long => _long;
  String get description => _description;
  String get wallPaper => _wallPaper;
  String get facebookLink => _facebookLink;

  String get twitterLink => _twitterLink;
  String get instagramLink => _instagramLink;
  String get displayPic => _displayPic;
  List get owner => _owner;

  Restaurant.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _name = pp[NAME];
    _description = pp[DESCRIPTION];
    _displayPic = pp[DISPLAYPIC];
    _facebookLink = pp[FACEBOOKLINK];
    _twitterLink = pp[TWITTERLINK];
    _instagramLink = pp[INSTAGRAMLINK];
    _images = pp[IMAGES] ?? [];
    _wallPaper = pp[STOREWALLPAPER];
    _owner = pp[OWNERS] ?? [];
    _long = pp[LONG];
    _lat = pp[LONG];

    _phoneNumber = pp[PHONENUMBER];
    _email = pp[EMAIL];
  }
}
