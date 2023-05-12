import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/thing_type.dart';

class Analytics {
  static const DIRECTORY = "analytics";

  static const COUNT = "count";
  static const MAXICOUNT = "maxi";
  static const DATE = "date";
  static const TYPE = "type";

  int _count;
  int _maxiCount;
  int _date;
  //int _total;
  String _type;

  int get count => _count;
  int get date => _date;
  //int get total => _total;
  int get maxi => _maxiCount;
  String get type => _type;

  Analytics.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _count = pp[COUNT] ?? 0;
    _maxiCount = pp[MAXICOUNT] ?? 0;
    _date = pp[DATE] ?? DateTime.now().millisecondsSinceEpoch;
    _type = pp[TYPE] ?? ThingType.PROPERTY;
    
    //_total = _count + _maxiCount;
  }
}
