import 'package:flutter/material.dart';
import 'package:hasior_flutter/screens/login_screen.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';
import '../services/api_service.dart';

class MenuNavigationDrawer extends StatefulWidget {
  const MenuNavigationDrawer({Key? key, required this.user}) : super(key: key);
  final User? user;

  @override
  State<MenuNavigationDrawer> createState() => _MenuNavigationDrawerState();
}

class _MenuNavigationDrawerState extends State<MenuNavigationDrawer> {
  static const grayColor = Color.fromRGBO(145, 149, 153, 1);
  var isLoaded = false;

  @override
  Widget build(BuildContext context) => Drawer(
          child: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              const Divider(
                color: grayColor,
                indent: 24,
                endIndent: 24,
              ),
              buildMenuItems(context),
              const Spacer(),
              widget.user != null ? buildMenuItemsBottom(context) : Container(),
            ],
          ),
        ),
      ]));

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
        ),
        child: userInfo(context),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: const [
            ListTile(
              leading: Icon(Icons.home_outlined),
              title: Text("Wydziały PK"),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Kalendarz wydarzeń"),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text("Zarząd"),
              onTap: null,
            ),
          ],
        ),
      );

  Widget buildMenuItemsBottom(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Ustawienia"),
              onTap: null,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Wyloguj"),
              onTap: () {
                ApiService().logout();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Home()));
              },
            ),
          ],
        ),
      );

  Widget userInfo(BuildContext context) {
    if (widget.user != null) {
      return Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.blue.shade700,
          ),
          const SizedBox(height: 12),
          Text(
            widget.user!.userName,
            style: const TextStyle(fontSize: 28, color: grayColor),
          ),
          Text(
            widget.user!.email,
            style: const TextStyle(fontSize: 16, color: grayColor),
          ),
          const SizedBox(height: 24),
        ],
      );
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            const Text("Niezalogowano", style: TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Zaloguj się"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const Login();
                }));
              },
            )
          ],
        ));
  }
}
