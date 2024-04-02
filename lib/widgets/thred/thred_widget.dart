import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/hasiorThred.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/thred/thred_card_widget.dart';

class ThredScreenWidget extends StatefulWidget {
  @override
  State<ThredScreenWidget> createState() => _thredScreen();
}

class _thredScreen extends State<ThredScreenWidget> {
  List<HasiorThred> thredList = [];
  bool isLoaded = false;

  Future<void> _getThreds([String? name]) async {
    try {
      UserWithToken? checkUser = await ApiService().userFromSharedPreferences();
      if (checkUser != null) {
        thredList = await ApiService().getAllUpcomingEventsForUser(name);
      } else {
        thredList = await ApiService().getAllUpcomingEvents(name);
      }
      if (thredList != null) {
        // calendarList = [];
        // dataEvents?.forEach((Calendar calendarElement) {
        //   calendarList
        //       .add(CalendarList(time: calendarElement.time, event: null));
        //   for (Event event in calendarElement.events) {
        //     calendarList.add(CalendarList(time: null, event: event));
        //   }
        };
        setState(() {
          isLoaded = true;
        });
      }
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
        ThredCardWidget(text: "first", owner: "Samorząd",),
      ],
    );
  }
}
