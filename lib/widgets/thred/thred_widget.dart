import 'package:flutter/material.dart';
import 'package:hasior_flutter/widgets/thred/thred_card_widget.dart';

class ThredScreen extends StatefulWidget {
  @override
  State<ThredScreen> createState() => _thredScreen();
}

class _thredScreen extends State<ThredScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
        ThredCardWidget(text: "first", imageLink: "assets/logo.png", owner: "Samorząd",),
      ],
    );
  }
}
