import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/calendar.dart';
import 'package:hasior_flutter/models/calendarList.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:hasior_flutter/theme.dart';
import 'package:hasior_flutter/widgets/navigator_drawer.dart';

class UserPanel extends StatefulWidget {
  const UserPanel({Key? key}) : super(key: key);

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  List<Calendar>? dataEvents;
  List<Calendar>? favouriteEvents;
  List<CalendarList> calendarList = [];
  List<CalendarList> calendarListFavourite = [];
  bool isSearching = false;
  int currentIndex = 0;
  bool isLoaded = false;
  bool isLoadedFavourite = false;
  UserWithToken? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(translation(context).admin_panel.capitalize()),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: drawerColor,
        ),
        child: MenuNavigationDrawer(
          user: user,
        ),
      ),
      extendBody: true,
      body: bodyContainer(),
    );
  }

  SizedBox bodyContainer() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: tableComponent(),
    );
  }

  DataTable tableComponent() {
    return DataTable(
      columns: generateTableColumns(),
      rows: [
        testRow(),
        testRow(),
      ],
    );
  }

  DataRow testRow() {
    return DataRow(
      cells: [
        DataCell(Text('Przykładowa Osoba')),
        DataCell(Text('przykladowy@email.com')),
        DataCell(Wrap(
          spacing: 5,
          children: [
            Chip(label: Text('Administrator')),
            Chip(label: Text('Użytkownik')),
          ],
        )),
        actionButtons()
      ],
    );
  }

  List<DataColumn> generateTableColumns() {
    return [
      const DataColumn(label: Text('Nazwa')),
      const DataColumn(label: Text('Email')),
      const DataColumn(label: Text('Role')),
      const DataColumn(label: Text('Akcje'))
    ];
  }

  DataCell actionButtons() {
    const editUser = 'Edytuj użytkownika';
    const deleteUser = 'Akcja 1';

    return DataCell(Align(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // Obsługa przycisku 1
            },
            child: const Text(editUser),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // Obsługa przycisku 2
            },
            child: const Text(deleteUser),
          ),
        ],
      ),
    ));
  }

}
