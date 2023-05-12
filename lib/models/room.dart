import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Room {
  static const DIRECTORY = "rooms";
  static const ROOMTYPE = "roomType";
  static const ROOMNUMBER = "roomNumber";
  static const DATEOFADDING = "date";
  static const PROPERTY = "property";

  static const MAINGUESTNAME = "mainGuestName";
  static const OTHERGUESTS = "otherGuests";
  static const DATES = "dates";

  static const START = "start";
  static const STOP = "stop";

  static const CURRENTOCCUPANT = "currentOccupant";
  static const ENDDATE = "endDate";
  static const SYSTEMGUEST = "systemGuest";

  int _totalGuestCount;
  String _roomType;
  String _id;
  String _roomNumber;
  Map _currentlyOngoingBookingDates;
  /* its structured like {bookingID:{
    start: int,
    stop: int,
  }} */
  String _currentOccupant;
  bool _systemGuest;

  int get totalGuestCount => _totalGuestCount;
  String get roomType => _roomType;
  String get id => _id;
  dynamic get dates => _currentlyOngoingBookingDates;
  String get roomNumber => _roomNumber;
  bool get systemGuest => _systemGuest;
  String get currentOccupant => _currentOccupant;

  RoomAvailability available(
    int startTime,
    int endTime,
  ) {
    RoomAvailability rA;

    if (startTime == null || endTime == null) {
      rA = RoomAvailability.tapHereToCheckBro;
    } else {
      bool inTheMiddle = false;
      bool available = false;

      if (_currentlyOngoingBookingDates.isEmpty) {
        available = true;
      } else {
        _currentlyOngoingBookingDates.forEach((key, value) {
          if (value[START] <= startTime && value[STOP] >= endTime) {
            inTheMiddle = true;
          }

          if (value[STOP] <= startTime || value[START] >= endTime) {
            available = true;
          }
        });
      }

      rA = available
          ? RoomAvailability.available
          : inTheMiddle
              ? RoomAvailability.occupied
              : RoomAvailability.tapHereToCheckBro;
    }

    return rA;
  }

  Room.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    Map pp = snapshot.data() as Map;

    _roomNumber = pp[ROOMNUMBER];
    _currentOccupant = pp[CURRENTOCCUPANT];
    _roomType = pp[ROOMTYPE];
    _currentlyOngoingBookingDates = pp[DATES] ?? {};
    _id = snapshot.id;
    _systemGuest = pp[SYSTEMGUEST];
  }
}

enum RoomAvailability {
  available,
  occupied,
  tapHereToCheckBro,
}

Color getRoomColorFromAvailability(
  BuildContext context,
  RoomAvailability rA,
) {
  return rA == RoomAvailability.tapHereToCheckBro
      ? Theme.of(context).canvasColor
      : roomColors[rA] ?? Colors.blue;
}

Map<RoomAvailability, Color> roomColors = {
  RoomAvailability.occupied: Colors.red,
  RoomAvailability.available: Colors.green,
};
