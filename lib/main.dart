import 'package:flutter/material.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:hasior_flutter/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studencka aPKa',
      theme: theme,
      home: const Home(title: 'Kalendarz wydarzeń'),
    );
  }
}
