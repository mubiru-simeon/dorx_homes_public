import 'package:flutter/material.dart';
import '../theming/theme_controller.dart';
import 'constants.dart';

TextStyle titleStyle = TextStyle(
  fontSize: 16,
  color: primaryColor,
  fontWeight: FontWeight.bold,
);

TextStyle smallWhiteTitle = TextStyle(
  color: Colors.white,
);

TextStyle whiteTitle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

TextStyle greyTitle = TextStyle(
  fontSize: 16,
);

TextStyle darkTitle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const vicinityBGPics = [
  trees,
  bus,
  scene,
];

const standardElevation = 5.0;
const borderDouble = 8.0;
BorderRadius standardBorderRadius = BorderRadius.circular(borderDouble);

String sharedPrefBrightness = "${capitalizedAppName}_brightness";

getTabColor(
  BuildContext context,
  bool selected,
) {
  Color selectedColor =
      ThemeBuilder.of(context).getCurrentTheme() == Brightness.dark
          ? Colors.white
          : Colors.black;
  Color notSelectedColor = selectedColor.withOpacity(0.5);

  return selected ? selectedColor : notSelectedColor;
}

const MaterialColor primaryColor = MaterialColor(
  0xffce9030,
  <int, Color>{
    50: Color(0xffce9030),
    100: Color(0xffce9030),
    200: Color(0xffce9030),
    300: Color(0xffce9030),
    400: Color(0xffce9030),
    500: Color(0xffce9030),
    600: Color(0xffce9030),
    700: Color(0xffce9030),
    800: Color(0xffce9030),
    900: Color(0xffce9030),
  },
);

const darkBgColor = primaryColor;
const altColor = Colors.blue;

const List<LinearGradient> listColors = [
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.indigoAccent,
      Colors.teal,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.purple,
      Colors.red,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.green,
      Colors.blue,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.orange,
      Colors.redAccent,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.purple,
      Colors.blue,
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffCE9FFC),
      Color(0xff7367F0),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFFF6B7),
      Color(0xffF6416C),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff43CBFF),
      Color(0xff9708CC),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFCCF31),
      Color(0xffF55555),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff3B2667),
      Color(0xffBC78EC),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFAB2FF),
      Color(0xff1904E5),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff81FFEF),
      Color(0xffF067B4),
    ],
  ),
];
