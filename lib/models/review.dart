import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  static const REVIEWDIRECTORY = "reviews";

  static const DATE = "date";
  static const SENDER = "sender";
  static const THINGID = "thingID";
  static const IMAGES = "images";
  static const TEXT = "text";
  static const RATING = "rating";
  static const LIKES = "likes";
  static const THINGTYPE = "thingType";
  static const DISLIKES = "dislikes";

  String _thingType;
  String _sender;
  String _thingID;
  List<dynamic> _images;
  String _text;
  int _date;
  double _rating;
  int _likes;
  int _dislikes;
  int _imagesCount;

  String get sender => _sender;
  int get imagesCount => _imagesCount;
  String get thingID => _thingID;
  List<dynamic> get images => _images;
  String get text => _text;
  String get thingType => _thingType;
  int get date => _date;
  double get rating => _rating;
  int get likes => _likes;
  int get dislikes => _dislikes;

  Review.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _date = pp[DATE];
    _dislikes = pp[DISLIKES] ?? 0;
    _images = pp[IMAGES];
    _thingType = pp[THINGTYPE];
    _likes = pp[LIKES] ?? 0;
    _rating = pp[RATING] ?? 0;
    _sender = snapshot.id;
    _text = pp[TEXT];
    _thingID = pp[THINGID];

    if (images == null) {
      _imagesCount = 0;
    } else {
      _imagesCount = _images.length;
    }
  }
}

class Rating {
  static const RATINGDIRECTORY = "ratings";
  static const AVERAGERATINGDIRECTORY = "averageRating";
  static const RATINGSCOUNT = "ratingsCount";

  static const ID = "id";
  static const ONE = "one";
  static const TWO = "two";
  static const THREE = "three";
  static const FOUR = "four";
  static const FIVE = "five";

  String _id;
  int _one;
  int _two;
  int _three;
  int _four;
  int _five;

  int get one => _one;
  int get two => _two;
  int get three => _three;
  int get four => _four;
  int get five => _five;

  String get id => _id;

  Rating.fromSnapshot(Map snapshot) {
    //_id = snapshot[ID];
    _one = snapshot[ONE] ?? 0;
    _three = snapshot[THREE] ?? 0;
    _two = snapshot[TWO] ?? 0;
    _four = snapshot[FOUR] ?? 0;
    _five = snapshot[FIVE] ?? 0;
  }
}
