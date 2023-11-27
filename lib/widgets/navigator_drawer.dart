import 'package:flutter/material.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/screens/login_screen.dart';
import 'package:hasior_flutter/screens/settings.dart';
import '../constants/language_constants.dart';
import '../models/userWithToken.dart';
import '../screens/home_screen.dart';
import '../services/api_service.dart';

class MenuNavigationDrawer extends StatefulWidget {
  const MenuNavigationDrawer({Key? key, required this.user}) : super(key: key);
  final UserWithToken? user;

  @override
  State<MenuNavigationDrawer> createState() => _MenuNavigationDrawerState();
}

class _MenuNavigationDrawerState extends State<MenuNavigationDrawer> {
  static const grayColor = Color.fromRGBO(145, 149, 153, 1);

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
                thickness: 0.1,
                indent: 18,
                endIndent: 18,
              ),
              buildMenuItems(context),
              const Spacer(),
              buildMenuItemsBottom(context),
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
        // padding: const EdgeInsets.symmetric(horizontal: 14),
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
        // padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(translation(context).settings.capitalize()),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const Settings();
                }));
              },
            ),
            widget.user != null
                ? ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(translation(context).log_out.capitalize()),
                    onTap: () {
                      ApiService().logout();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => const Home()));
                    },
                  )
                : Container(),
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
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Image.asset("assets/logo.png"),
            ),
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
        // padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
      children: [
        Text(translation(context).not_logged_in.capitalize(),
            style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.login),
          title: Text(translation(context).log_in.capitalize()),
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
