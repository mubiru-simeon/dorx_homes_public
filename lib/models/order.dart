import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  static const DIRECTORY = 'orders';

  static const MODEL = "model";
  static const PRICE = "price";
  static const QUANTITY = "quantity";
  static const FOOD = "food";
  static const VARIATION = "variation";
  static const FOODNAME = "foodName";

  static const CUSTOMERS = "customers";
  static const DATE = "date";
  static const THINGID = "thingID";
  static const CUSTOMERMAP = "customerMap";
  static const CUSTOMERAMOUNTS = "customerAmounts";
  static const CUSTOMERTYPE = "customerType";
  static const THINGTYPE = "thingType";
  static const ADDER = "adder";

  dynamic _customerMap;
  dynamic _customerAmounts;
  String _id;
  int _date;
  List _customers;
  String _thingID;
  dynamic _food;
  String _thingType;

  dynamic get customerMap => _customerMap;
  List get customers => _customers;
  dynamic get food => _food;
  dynamic get customerAmounts => _customerAmounts;
  int get date => _date;
  String get thingID => _thingID;
  String get thingType => _thingType;
  String get id => _id;

  Order.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _thingID = pp[THINGID];
    _customers = pp[CUSTOMERS] ?? [];
    _thingType = pp[THINGTYPE];
    _food = pp[FOOD] ?? [];
    _customerAmounts = pp[CUSTOMERAMOUNTS] ?? {};
    _date = pp[DATE];
    _customerMap = pp[CUSTOMERMAP] ?? {};
  }
}
