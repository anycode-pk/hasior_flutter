import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/globalSnackbar.dart';
import 'package:hasior_flutter/classes/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/calendar.dart';
import 'package:hasior_flutter/models/calendarList.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/theme.dart';
import 'package:hasior_flutter/widgets/calendar_widget.dart';
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
      body: tableComponent(),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Table tableComponent() {
    return Table(
      border: TableBorder.all(),
      //columnWidths: const <int, TableColumnWidth>{
      //0: IntrinsicColumnWidth(),
      //1: FlexColumnWidth(),
      //2: FixedColumnWidth(64),
      //},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        createTableRow(["Hej1", "Hej2", "Hej3", "Hej4"])
      ],
    );
  }

  TableRow createTableRow(List<String> names) {
    return TableRow(
      children: names.map((cell) => createCell(cell)).toList()
    );
  }

  TableCell createCell(String cellName) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.top,
      child: Text(cellName),
    );
  }

  Widget? bottomNavigationBar() {
    return user != null
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, primaryBlack.withOpacity(0.4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Container(
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: primaryBlack,
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  currentIndex: currentIndex,
                  onTap: (index) => setState(() {
                    currentIndex = index;
                  }),
                  items: [
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.calendar_month),
                        label: translation(context).all_events.capitalize()),
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.favorite),
                        label:
                            translation(context).favorite_events.capitalize()),
                  ],
                )),
          )
        : null;
  }
}
