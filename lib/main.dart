import 'package:flutter/material.dart';
import 'package:hasior_flutter/theme.dart';

import 'navigator_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studencka aPKa',
      theme: theme,
      home: const MyHomePage(title: 'Kalendarz wydarzeń'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: drawerColor,
        ),
        child: const NavigationDrawer(),
      ),
      body: Center(
          child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              itemCount: 50,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                return buildCard(index);
              })),
    );
  }

  Widget buildCard(int index) => Container(
      color: const Color.fromRGBO(49, 52, 57, 1),
      width: double.infinity,
      height: 90,
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
                left: BorderSide(
          color: grayColor,
          width: 7.0,
        ))),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Koncert Who is Who $index",
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  "19:50",
                  style:
                      TextStyle(color: grayColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
                        child: const Icon(
                          Icons.location_pin,
                          color: grayColor,
                        ),
                      ),
                      const Expanded(
                        child: Text("Politechnika Koszalińska",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: grayColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  children: const [
                    Text("Uczestniczysz",
                        style: TextStyle(
                            color: Color.fromRGBO(0, 150, 136, 1), fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(
                      Icons.check_circle_outline,
                      color: Color.fromRGBO(0, 150, 136, 1),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ));
}
