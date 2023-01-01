import 'package:flutter/material.dart';

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFFE1E1E1),
    100: Color(0xFFB3B3B3),
    200: Color(0xFF808181),
    300: Color(0xFF4D4E4E),
    400: Color(0xFF272828),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF010202),
    700: Color(0xFF010101),
    800: Color(0xFF010101),
    900: Color(0xFF000101),
  },
);
const int _blackPrimaryValue = 0xFF010202;

const accentColor = Color(0xFF4574E8);
const drawerColor = Color.fromRGBO(24, 32, 38, 1);

final ThemeData theme = ThemeData(
  primarySwatch: primaryBlack,
  brightness: Brightness.dark,
  primaryColor: const Color(0xff000000),
  scaffoldBackgroundColor: const Color(0xff15181E),
  disabledColor: const Color.fromARGB(120, 255, 255, 255),
  appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      iconTheme: IconThemeData(color: accentColor)),
  buttonTheme: const ButtonThemeData(
    buttonColor: accentColor,
  ),
  bottomAppBarColor: accentColor,
  dividerColor: Colors.white,
);
