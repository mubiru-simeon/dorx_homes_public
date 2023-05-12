import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'models.dart';

class Property {
  static const DIRECTORY = "properties";
  static const FEATUREDPROPERTIES = "featuredProperties";

  static const NEARBYUNIVERSITY = "nearbyUniversity";
  static const NAME = "name";
  static const CATEGORY = "category";
  static const CATEGORYTYPE = "categoryType";
  static const DESCRIPTION = "description";
  static const PETSALLOWED = "petsAllowed";
  static const RESIDENTIAL = "residential";
  static const COMMERCIAL = "commercial";

  static const TOWNTOPS = "townTops";
  static const OWNER = "owners";
  static const FIRSTPRICE = "firstPrice";
  static const LASTPRICE = "lastPrice";
  static const VICINITIES = "vicinities";
  static const OWNERSMAP = "ownersMap";
  static const FEATURED = "featured";
  static const PRICE = "price";
  static const SHAREDWITHWHO = "sharedwithWho";
  static const FREQUENCY = "frequency";
  static const HOUSETYPE = "houseType";
  static const SALEMODE = "saleMode";
  static const SIZETYPE = "sizeType";
  static const AVAILABLE = "available";
  static const TENURE = "tenure";
  static const SIZE = "size";
  static const YEAR = "year";
  static const EASYBOOK = "easyBook";
  static const SETTINGSMAP = "settingsMap";

  static const HOUSERULES = "houseRules";
  static const ADDITIONALHOUSERULES = "additionalHouseRules";
  static const BUTTONTEXT = "buttonText";
  static const LAT = "lat";
  static const LONG = "long";
  static const SHUTTLE = "shuttle";
  static const WELLBEINGAMENITIES = "wellbeingAmenities";
  static const LUXURYAMENITIES = "luxuryAmenities";
  static const SECURITYAMENITIES = "securityAmenities";
  static const TIMEOFADDING = "date";
  static const IMAGES = "images";
  static const OWNERS = "owners";
  static const OWNERMAP = "ownerMap";

  String _name;
  String _description;
  List _category;
  String _tenure;
  dynamic _price;
  int _timeOfAdding;
  String _year;
  List _vicinities;
  dynamic _firstPrice;
  dynamic _lastPrice;
  String _displayPic;
  String _sharedWithWho;
  String _saleMode;
  String _country;
  String _nearbyUniversity;
  dynamic _settingsMap;
  dynamic _size;
  String _city;
  String _buttonText;
  bool _easyBook;
  bool _available;
  String _houseType;
  String _sizeType;
  bool _petsAllowed;
  dynamic _houseRules;
  dynamic _additionalRules;
  List _luxuryAmenities;
  dynamic _ownersMap;
  List _securityAmenities;
  String _frequency;
  String _categoryType;
  List _owner;
  bool _shuttle;
  List _images;
  List _wellbeingAmenities;
  double _long;
  double _lat;
  String _id;
  String _address;

  String get name => _name;
  String get description => _description;
  bool get shuttle => _shuttle;
  String get displayPic => _displayPic;
  String get frequency => _frequency;
  String get buttonText => _buttonText;
  String get address => _address;
  String get tenure => _tenure;
  List get cateogry => _category;
  dynamic get settingsMap => _settingsMap;
  bool get petsAllowed => _petsAllowed;
  dynamic get firstPrice => _firstPrice;
  dynamic get lastPrice => _lastPrice;
  String get sizeType => _sizeType;
  bool get available => _available;
  String get year => _year;
  bool get easyBook => _easyBook;
  String get categoryType => _categoryType;
  List get vicinities => _vicinities;
  dynamic get price => _price;
  dynamic get ownersMap => _ownersMap;

  dynamic get houseRules => _houseRules;
  String get nearbyUniversity => _nearbyUniversity;
  dynamic get additionalRules => _additionalRules;
  dynamic get size => _size;
  String get saleMode => _saleMode;
  String get houseType => _houseType;
  int get timeOfAdding => _timeOfAdding;
  String get country => _country;
  String get city => _city;
  String get id => _id;
  String get sharedWithWho => _sharedWithWho;
  List get owners => _owner;
  List get images => _images;
  List get wellbeingAmenities => _wellbeingAmenities;
  List get luxuryAmenities => _luxuryAmenities;
  List get securityAmenities => _securityAmenities;
  double get long => _long;
  double get lat => _lat;

  Property.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    Map pp = snapshot.data() as Map;

    _name = pp[NAME];
    _description = pp[DESCRIPTION];
    _category = pp[CATEGORY] ?? [];
    _settingsMap = pp[SETTINGSMAP] ?? {};
    _owner = pp[OWNER] ?? [];
    _year = pp[YEAR];
    _saleMode = pp[SALEMODE];
    _size = pp[SIZE];
    _price = pp[PRICE];
    _vicinities = pp[VICINITIES] ?? [];
    _tenure = pp[TENURE];
    _available = pp[AVAILABLE] ?? false;
    _sharedWithWho = pp[SHAREDWITHWHO];
    _frequency = pp[FREQUENCY] ?? PERNIGHT;
    _categoryType = pp[CATEGORYTYPE] ?? Property.RESIDENTIAL;
    _ownersMap = pp[OWNERSMAP] ?? {};
    _address = pp[GeoHashedItem.ADDRESS];
    _petsAllowed = pp[PETSALLOWED] ?? true;
    _shuttle = pp[SHUTTLE] ?? false;
    _buttonText = pp[BUTTONTEXT] ?? "Book now";
    _firstPrice = pp[FIRSTPRICE];
    _lastPrice = pp[LASTPRICE];
    _easyBook = pp[EASYBOOK] ?? true;
    _additionalRules = pp[ADDITIONALHOUSERULES] ?? {};
    _nearbyUniversity = pp[NEARBYUNIVERSITY];
    _country = pp[GeoHashedItem.COUNTRY];
    _city = pp[GeoHashedItem.CITY];
    _houseRules = pp[HOUSERULES] ?? {};
    _sizeType = pp[SIZETYPE] ?? ACRES;
    _id = snapshot.id;
    _timeOfAdding = pp[TIMEOFADDING];
    _houseType = pp[HOUSETYPE];
    _images = pp[IMAGES];
    _wellbeingAmenities = pp[WELLBEINGAMENITIES];
    _luxuryAmenities = pp[LUXURYAMENITIES] ?? [];
    _securityAmenities = pp[SECURITYAMENITIES];
    _long = pp[LONG];
    _lat = pp[LAT];
  }
}

const PERNIGHT = "per Night";
const PERMONTH = "per Month";
const PERWEEK = "per Week";
const PERSEMISTER = "per Semister";

const HECTARES = "hectares";
const ACRES = "acres";
const DECIMALS = "decimals";

const PEACEFUL = "peaceful";
const SPACIOUS = "spacious";
const QUIET = "quiet";
const FAMILYFRIENDLY = "family-friendly";
const SCENIC = "scenic";
const REMOTE = "remote";
const PARTY = "party";
const BUSINESSFRIENDLY = "business-friendly";

const FORRENT = "for rent";
const FORSALE = "for sale";

Map<String, IconData> sellageModes = {
  FORRENT: Icons.house,
  FORSALE: Icons.monetization_on_sharp,
};

Map<String, IconData> availableHighlights = {
  PEACEFUL: FontAwesomeIcons.peace,
  SPACIOUS: Icons.people,
  FAMILYFRIENDLY: Icons.family_restroom,
  BUSINESSFRIENDLY: FontAwesomeIcons.moneyBill,
  QUIET: Icons.surround_sound,
  SCENIC: Icons.beach_access,
  REMOTE: FontAwesomeIcons.diamondTurnRight,
  PARTY: Icons.party_mode,
};

const ENTIREPLACE = "entirePlace";
const PRIVATEROOM = "privateRoom";
const SHAREDROOM = "sharedRoom";
const SHAREDWITHOTHERRENTERS = "sharedWithOtherRenters";
const SHAREDWITHPROPERTY = "sharedWithProperty";
const SHAREDWITHFAMILY = "sharedWithFamily";

Map houseOptions = {
  ENTIREPLACE: {},
  PRIVATEROOM: {},
  SHAREDROOM: {
    "content": [
      SHAREDWITHOTHERRENTERS,
      SHAREDWITHPROPERTY,
      SHAREDWITHFAMILY,
    ]
  },
};

String getTileText(String text) {
  return text == ENTIREPLACE
      ? "Entire Place"
      : text == SHAREDWITHFAMILY
          ? "Shared with some of the host's family"
          : text == SHAREDWITHOTHERRENTERS
              ? "Shared with other renters / guests"
              : text == SHAREDWITHPROPERTY
                  ? "Shared with some of the host's property"
                  : "Private Room";
}

Map sizes = {
  HECTARES: 2.47105,
  ACRES: 1,
  DECIMALS: 0.01,
};
