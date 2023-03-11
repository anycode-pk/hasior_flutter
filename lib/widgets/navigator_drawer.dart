import 'package:flutter/material.dart';

class MenuNavigationDrawer extends StatelessWidget {
  const MenuNavigationDrawer({Key? key}) : super(key: key);
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
                indent: 24,
                endIndent: 24,
              ),
              buildMenuItems(context),
              const Spacer(),
              buildMenuItemsBottom(context)
            ],
          ),
        ),
      ]));

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.blue.shade700,
            ),
            const SizedBox(height: 12),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 28, color: grayColor),
            ),
            const Text(
              'john.doe@gmail.com',
              style: TextStyle(fontSize: 16, color: grayColor),
            )
          ],
        ),
      );
  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Wydziały PK'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Kalendarz wydarzeń'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Zarząd'),
              onTap: () {},
            ),
          ],
        ),
      );

  Widget buildMenuItemsBottom(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ustawienia'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Wyloguj'),
              onTap: () {},
            ),
          ],
        ),
      );
}
