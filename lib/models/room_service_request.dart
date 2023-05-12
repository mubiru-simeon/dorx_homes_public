import 'package:cloud_firestore/cloud_firestore.dart';

class RoomServiceRequest {
  static const DIRECTORY = "roomServiceRequests";

  static const PROPERTY = "property";
  static const TENANTID = "tenantID";
  static const PENDING = "pending";
  static const DATE = "date";

  String _id;
  String _tenant;
  String _property;

  String get id => _id;
  String get tenant => _tenant;
  String get property => _property;

  RoomServiceRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _tenant = pp[TENANTID];
  }
}
