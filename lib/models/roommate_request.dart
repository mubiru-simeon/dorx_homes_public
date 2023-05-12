import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateRequest {
  static const DIRECTORY = "roommateRequests";

  static const REQUESTER = "requester";
  static const TIME = "time";
  static const TEXT = "text";
  static const SEEKERGENDER = "seekerGender";
  static const SEEKEEGENDER = "seekeeGender";
  static const SEEKERDETAILS = "seekerDetails";
  static const SEEKERNAME = "seekerName";
  static const ROOMRULES = "roomRules";
  static const PHONENUMBER = "phoneNumber";
  static const MATCHED = "matched";

  int _time;
  String _seekerGender;
  String _seekeeGender;
  String _name;
  String _rules;
  String _details;
  String _id;
  String _text;
  String _requester;
  String _phoneNumber;
  bool _matched;

  int get time => _time;
  String get phoneNumber => _phoneNumber;
  String get text => _text;
  String get name => _name;
  String get seekerGender => _seekerGender;
  String get seekeeGender => _seekeeGender;
  String get details => _details;
  bool get matched => _matched;
  String get requester => _requester;
  String get rules => _rules;
  String get id => _id;

  RoommateRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _time = pp[TIME] ?? DateTime.now().millisecondsSinceEpoch;
    _text = pp[TEXT] ?? "";
    _phoneNumber = pp[PHONENUMBER] ?? "";
    _details = pp[SEEKERDETAILS];
    _rules = pp[ROOMRULES];
    _seekeeGender = pp[SEEKEEGENDER];
    _requester = pp[REQUESTER];
    _seekerGender = pp[SEEKERGENDER];
    _name = pp[SEEKERNAME];

    _matched = pp[MATCHED] ?? false;
  }
}
