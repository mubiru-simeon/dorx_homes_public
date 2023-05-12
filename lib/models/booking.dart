import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  static const DIRECTORY = "bookings";

  static const START = "start";
  static const PROPERTY = "property";
  static const STOP = "stop";
  static const OWNER = "owner";
  static const ADULTCOUNT = "adultCount";
  static const CHILDCOUNT = "childCount";
  static const PETCOUNT = "petCount";
  static const CUSTOMERMAP = "customerMap";
  static const CUSTOMER = "customer";
  static const PROPERTYPRICE = "propertyPrice";
  static const CHECKERIN = "checkerIn";
  static const DATEOFCHECKINGIN = "dateOfCheckingIn";
  static const PAYMENTAMOUNT = "paymentAmount";
  static const DATE = "date";
  static const BUYER = "buyer";
  static const DATEOFPAYMENT = "dateOfPayment";
  static const OFFEREDROOMS = "offeredRooms";
  static const SELECTEDROOMS = "selectedRooms";
  static const LUGGAGE = "luggage";
  static const CHECKEDINGUESTS = "checkedInGuests";
  static const INEEDALIFT = "needALift";

  //booking states
  static const PENDING = "pending";
  static const COMPLETE = "complete";
  static const CANCELLED = "cancelled";
  static const APPROVED = "approved";
  static const REJECTED = "rejected";
  static const ONGOING = "ongoing";
  static const CHECKEDIN = "checkedIn";

  String _customer;
  bool _pending;
  List _roomsRequested;
  bool _cancelled;
  bool _rejected;
  bool _complete;
  bool _ongoing;
  bool _checkedIn;
  bool _approved;

  String get customer => _customer;
  bool get pending => _pending;
  bool get cancelled => _cancelled;
  bool get rejected => _rejected;
  bool get complete => _complete;
  bool get ongoing => _ongoing;
  List get roomsRequested => _roomsRequested;
  bool get checkedIn => _checkedIn;
  bool get approved => _approved;

  Booking.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _customer = pp[CUSTOMER];
    _pending = pp[PENDING];
    _cancelled = pp[CANCELLED];
    _rejected = pp[REJECTED];
    _complete = pp[COMPLETE];
    _ongoing = pp[ONGOING];
    _checkedIn = pp[CHECKEDIN];
    _roomsRequested = pp[SELECTEDROOMS] ?? [];
    _approved = pp[APPROVED];
  }
}
