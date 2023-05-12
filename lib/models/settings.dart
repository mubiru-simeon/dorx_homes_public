class DorxSettings {
  static const DORXBOXNAME = "dorxHomesBox";
  static const SEARCHHISTORY = "searchHistory";

  static const PREFSMAP = "prefsMap";
  static const FINISHEDONBOARDING = "finishedOnboarding";

  static const ADULTCOUNT = "adultCount";
  static const CHILDCOUNT = "childCount";
  static const PETCOUNT = "petCount";
  static const STARTDATE = "startDate";
  static const STOPDATE = "stopDate";
  static const LAT = "lat";
  static const VICINITIES = "vicinities";
  static const LONG = "long";

  static const EMAILNOTIFICATIONS = "emailNotifications";

  bool _emailNotifications;
  int _adultCount;
  int _childCount;
  int _petCount;
  int _startDate;
  int _stopDate;
  List _vicinities;
  dynamic _lat;
  dynamic _long;

  bool get emailNotifications => _emailNotifications ?? true;
  int get adultCount => _adultCount;
  int get childCount => _childCount;
  int get petCount => _petCount;
  int get startDate => _startDate;
  int get stopDate => _stopDate;
  List get vicinities => _vicinities;
  dynamic get lat => _lat;
  dynamic get long => _long;

  DorxSettings.fromMap(
    dynamic userMap,
    dynamic prefsMap,
  ) {
    _adultCount = prefsMap[ADULTCOUNT] ?? 1;
    _childCount = prefsMap[CHILDCOUNT] ?? 0;
    _petCount = prefsMap[PETCOUNT] ?? 0;
    _startDate = prefsMap[STARTDATE];
    _stopDate = prefsMap[STOPDATE];
    _vicinities = prefsMap[VICINITIES] ?? [];
    _lat = prefsMap[LAT];
    _long = prefsMap[LONG];

    if (userMap != null) {
      _emailNotifications = userMap[EMAILNOTIFICATIONS] ?? false;
    }
  }
}

Map getSettingsMap(DorxSettings settings) {
  Map pp = {};

  pp.addAll({
    DorxSettings.ADULTCOUNT: settings.adultCount,
    DorxSettings.CHILDCOUNT: settings.childCount,
    DorxSettings.PETCOUNT: settings.petCount,
    DorxSettings.LAT: settings.lat,
    DorxSettings.LONG: settings.long,
    DorxSettings.STARTDATE: settings.startDate,
    DorxSettings.STOPDATE: settings.stopDate,
    DorxSettings.VICINITIES: settings.vicinities,
  });

  return pp;
}
