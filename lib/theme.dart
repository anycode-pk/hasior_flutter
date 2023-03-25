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

const MaterialColor primarycolor =
    MaterialColor(_primarycolorPrimaryValue, <int, Color>{
  50: Color(0xFFE9EEFC),
  100: Color(0xFFC7D5F8),
  200: Color(0xFFA2BAF4),
  300: Color(0xFF7D9EEF),
  400: Color(0xFF6189EB),
  500: Color(_primarycolorPrimaryValue),
  600: Color(0xFF3E6CE5),
  700: Color(0xFF3661E2),
  800: Color(0xFF2E57DE),
  900: Color(0xFF1F44D8),
});
const int _primarycolorPrimaryValue = 0xFF4574E8;

const accentColor = Color(0xFF4574E8);
const drawerColor = Color.fromRGBO(24, 32, 38, 1);

final ThemeData theme = ThemeData(
    primarySwatch: primarycolor,
    brightness: Brightness.dark,
    primaryColor: accentColor,
    scaffoldBackgroundColor: const Color(0xff15181E),
    disabledColor: const Color.fromARGB(120, 255, 255, 255),
    appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlack,
        iconTheme: IconThemeData(color: accentColor)),
    buttonTheme: const ButtonThemeData(
      buttonColor: accentColor,
    ),
    dividerColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryBlack, selectedItemColor: primarycolor));
