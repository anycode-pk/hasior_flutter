import 'package:flutter/material.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/screens/admin/user_list_screen.dart';
import 'package:hasior_flutter/screens/login_screen.dart';
import 'package:hasior_flutter/screens/threds/add_to_secret_inbox_screen.dart';
import 'package:hasior_flutter/screens/threds/partners_screen.dart';
import 'package:hasior_flutter/screens/qr_scanner_screen.dart';
import 'package:hasior_flutter/screens/requests_calendar_screen.dart';
import 'package:hasior_flutter/screens/settings_screen.dart';
import 'package:hasior_flutter/screens/threds/secret_inbox_screen.dart';
import 'package:hasior_flutter/screens/threds/self-governance_screen.dart';
import 'package:hasior_flutter/screens/tickets_screen.dart';
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
              widget.user != null ? buildMenuItems(context) : Container(),
              widget.user != null && widget.user!.isAdmin()
                  ? buildAdminMenuItems(context)
                  : Container(),
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

  Widget buildMenuItems(BuildContext context) => Column(
        children: [
          ListTile(
            // leading: const Icon(Icons.airplane_ticket_rounded),
            title: Text(translation(context).my_tickets.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Tickets();
              }));
            },
          ),
          ListTile(
            // leading: const Icon(Icons.airplane_ticket_rounded),
            title: Text(translation(context).partners.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Partners();
              }));
            },
          ),
          ListTile(
            // leading: const Icon(Icons.airplane_ticket_rounded),
            title: Text(translation(context).self_governance.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SelfGovernance();
              }));
            },
          ),
          ListTile(
            // title: Text(translation(context).manage_students.capitalize()),
            title: Text("Masz problem? Daj nam znać!"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AddToSecretInbox();
              }));
            },
          ),
        ],
      );

  Widget buildAdminMenuItems(BuildContext context) => Column(
        children: [
          const Divider(
            color: grayColor,
            thickness: 0.1,
            indent: 18,
            endIndent: 18,
          ),
          ListTile(
            title: Text(translation(context).ticket_check.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const QrScanner();
              }));
            },
          ),
          ListTile(
            title: Text(translation(context).ticket_requests.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const RequestsCalendar();
              }));
            },
          ),
          ListTile(
            title: Text(translation(context).manage_students.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const UserList();
              }));
            },
          ),
          ListTile(
            title: Text(translation(context).secret_inbox.capitalize()),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SecretInbox();
              }));
            },
          )
        ],
      );

  Widget buildMenuItemsBottom(BuildContext context) => Column(
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
    return Column(
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
    );
  }
}
