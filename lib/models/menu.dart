import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  static const DIRECTORY = "menu";

  static const NAME = "name";
  static const DESCRIPTION = "description";
  static const IMAGES = "images";
  static const RESTAURANT = "restaurant";
  static const BGCOLOR = "bgColor";
  static const FOOD = "food";
  static const DATEADDED = "added";
  static const THEME = "theme";

  String _name;
  String _description;
  String _color;
  String _id;
  List _images;
  String _restaurant;
  String _theme;

  dynamic _rawFoodMap;
  List<MenuCategory> _food;
  /*   burgers: {
    images : [],
    food: []
  } */
  int _dateAdded;

  String get name => _name;
  String get description => _description;
  String get theme => _theme;
  List get images => _images;
  String get id => _id;
  String get restaurant => _restaurant;
  dynamic get rawFoodMap => _rawFoodMap;
  List<MenuCategory> get food => _food;
  String get color => _color;
  int get dateAdded => _dateAdded;

  Menu.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _name = pp[NAME];
    _description = pp[DESCRIPTION];
    _id = snapshot.id;
    _images = pp[IMAGES] ?? [];
    _restaurant = pp[RESTAURANT];
    _rawFoodMap = pp[FOOD] ?? {};
    _color = pp[BGCOLOR];
    _theme = pp[THEME];
    _dateAdded = pp[DATEADDED];

    List<MenuCategory> fd = [];
    _rawFoodMap.forEach((key, value) {
      MenuCategory menuCategory = MenuCategory.fromMap(
        value,
        key,
      );

      fd.add(menuCategory);
    });

    _food = fd;
  }

  Menu.fromData({
    String name,
    String description,
    List images,
    String restaurant,
    Map food,
    String color,
    String theme,
  }) {
    _name = name;
    _description = description;
    _images = images ?? [];
    _color = color;
    _theme = theme;
    _restaurant = restaurant;
    _rawFoodMap = food;
    _dateAdded = DateTime.now().millisecondsSinceEpoch;

    List<MenuCategory> fd = [];
    _rawFoodMap.forEach((key, value) {
      MenuCategory menuCategory = MenuCategory.fromMap(
        value,
        key,
      );

      fd.add(menuCategory);
    });

    _food = fd;
  }
}

class MenuCategory {
  static const NAME = "name";
  static const FOOD = "food";
  // static const IMAGES = "images";

  String _name;
  List _food;
  // List _images;

  String get name => _name;
  List get food => _food;
  // List get images => _images;

  MenuCategory.fromMap(
    Map mp,
    String name,
  ) {
    _name = name;
    _food = mp[FOOD];
    // _images = mp[IMAGES];
  }
}