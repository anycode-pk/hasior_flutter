import 'dart:async';

import 'package:flutter/material.dart';

import 'Auth/login_page.dart';
import 'ChatPage.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {

  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 5),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginView())),
    );
    _loadUserInfo();
  }

  _loadUserInfo() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}