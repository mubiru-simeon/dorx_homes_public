import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class RoomType {
  static const DIRECTORY = "roomTypes";

  static const NAME = "name";
  static const PRICE = "price";
  static const PAYMENTFREQUENCY = "paymentFrequency";
  static const PROPERTY = "property";
  static const IMAGES = "images";
  static const DESCRIPTION = "description";
  static const TOTALGUESTCOUNT = "totalGuestCount";
  static const SELFCONTAINED = "selfContained";
  static const BATHROOMS = "bathrooms";
  static const ALREADYONLINE = "alreadyOnline";

  String _id;
  String _name;
  String _description;
  int _totalGuestCount;
  dynamic _price;
  String _paymentFrequency;
  bool _selfContained;
  List _images;
  int _bathroomCount;

  String get id => _id;
  String get name => _name;
  String get description => _description;
  List get images => _images;
  int get totalGuestCount => _totalGuestCount;
  int get bathroomCount => _bathroomCount;
  bool get selfContained => _selfContained;
  String get paymentFrequency => _paymentFrequency;
  dynamic get price => _price;

  RoomType.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;
    _id = snapshot.id;
    _name = pp[NAME] ?? "";
    _description = pp[DESCRIPTION];
    _paymentFrequency = pp[PAYMENTFREQUENCY] ?? PERNIGHT;
    _images = pp[IMAGES] ?? [];
    _price = pp[PRICE];
    _bathroomCount = pp[BATHROOMS] ?? 1;
    _totalGuestCount = pp[TOTALGUESTCOUNT] ?? 1;
    _selfContained = pp[SELFCONTAINED] ?? false;
  }
}
