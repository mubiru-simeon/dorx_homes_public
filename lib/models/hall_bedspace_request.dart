import 'package:cloud_firestore/cloud_firestore.dart';

class HallBedspaceRequest {
  static const DIRECTORY = "bedspaceRequests";
  static const IHAVEAROOM = "bedspaceOffers";

  static const PENDING = "pending";
  static const COMPLETED = "completed";
  static const UNIVERSITY = "university";
  static const GENDER = "gender";
  static const CUSTOMER = "customer";
  static const DATE = "date";

  String _university;
  int _date;
  String _id;
  String _gender;

  String get university => _university;
  int get date => _date;
  String get gender => _gender;
  String get id => _id;

  HallBedspaceRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _university = pp[UNIVERSITY];
    _gender = pp[GENDER] ?? "male";
    _date = pp[DATE] ?? DateTime.now().millisecondsSinceEpoch;
  }
}
