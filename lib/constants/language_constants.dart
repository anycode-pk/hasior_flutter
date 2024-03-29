import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String LAGUAGE_CODE = "languageCode";

const String ENGLISH = "en";
const String POLISH = "pl";

Future<Locale?> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale?> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString(LAGUAGE_CODE);
  return _locale(languageCode);
}

Locale? _locale(String? languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, "");
    case POLISH:
      return const Locale(POLISH, "");
    default:
      return null;
  }
}

AppLocalizations translation(BuildContext context) {
  return AppLocalizations.of(context)!;
}
