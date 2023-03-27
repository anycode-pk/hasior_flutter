import 'package:flutter/material.dart';
import 'package:hasior_flutter/class/globalSnackbar.dart';
import 'package:hasior_flutter/widgets/calendar_widget.dart';
import '../models/calendarList.dart';
import '../models/calendar.dart';
import '../models/user.dart';
import '../widgets/navigator_drawer.dart';
import '../services/api_service.dart';
import '../theme.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Calendar>? dataEvents;
  List<Calendar>? favouriteEvents;
  List<CalendarList> calendarList = [];
  List<CalendarList> calendarListFavourite = [];
  bool isSearching = false;
  int currentIndex = 0;
  bool isLoaded = false;
  bool isLoadedFavourite = false;
  User? user;

  @override
  void initState() {
    super.initState();
    _getUser();
    _getEvents();
    _getFavouriteEvents();
  }

  Future _getUser() async {
    user = await ApiService().userFromSharedPreferences();
  }

  Future _getEvents([String? name]) async {
    try {
      dataEvents = await ApiService().getCalendarEvents(name);
      if (dataEvents != null) {
        calendarList = [];
        dataEvents?.forEach((element) {
          calendarList.add(CalendarList(time: element.time, events: null));
          for (var element in element.events) {
            calendarList.add(CalendarList(time: null, events: element));
          }
        });
        setState(() {
          isLoaded = true;
        });
      }
    } catch (e) {
      GlobalSnackbar.errorSnackbar(context, "Błąd podczas ładowania");
    }
  }

  Future _getFavouriteEvents([String? name]) async {
    try {
      var checkUser = await ApiService().userFromSharedPreferences();
      if (checkUser != null) {
        favouriteEvents = await ApiService().getFavouriteEvents(name);
        if (favouriteEvents != null) {
          calendarListFavourite = [];
          favouriteEvents?.forEach((element) {
            calendarListFavourite
                .add(CalendarList(time: element.time, events: null));
            for (var element in element.events) {
              calendarListFavourite
                  .add(CalendarList(time: null, events: element));
            }
          });
          setState(() {
            isLoadedFavourite = true;
          });
        }
      }
    } catch (e) {
      GlobalSnackbar.errorSnackbar(context, "Błąd podczas ładowania");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      CalendarWidget(
        isLoaded: isLoaded,
        calendarList: calendarList,
        dataEvents: dataEvents,
        getData: _getEvents,
        delete: false,
        user: user,
      ),
      CalendarWidget(
        isLoaded: isLoadedFavourite,
        calendarList: calendarListFavourite,
        dataEvents: favouriteEvents,
        getData: _getFavouriteEvents,
        delete: true,
        user: user,
      )
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Kalendarz wydarzeń"),
        // title: !isSearching
        //     ? const Text("Kalendarz wydarzeń")
        //     : TextField(
        //         onChanged: (value) {
        //           _filter(value);
        //         },
        //         style: const TextStyle(color: Colors.white),
        //         decoration: const InputDecoration(
        //             icon: Icon(
        //               Icons.search,
        //               color: Colors.white,
        //             ),
        //             hintText: "Wyszukaj...",
        //             hintStyle: TextStyle(color: Colors.white)),
        //       ),
        // actions: !isSearching
        //     ? [
        //         // Navigate to the Search Screen
        //         IconButton(
        //             onPressed: () => {
        //                   setState(() {
        //                     isSearching = true;
        //                   })
        //                 },
        //             icon: const Icon(Icons.search))
        //       ]
        //     : [
        //         IconButton(
        //             onPressed: () => {
        //                   setState(() {
        //                     isSearching = false;
        //                     filteredCalendarList = calendarList;
        //                   })
        //                 },
        //             icon: const Icon(Icons.clear))
        //       ],
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: drawerColor,
        ),
        child: MenuNavigationDrawer(
          user: user,
        ),
      ),
      body: screens[currentIndex],
      bottomNavigationBar: user != null
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => setState(() {
                if (currentIndex != index) {
                  _getEvents();
                  _getFavouriteEvents();
                }
                currentIndex = index;
              }),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month), label: "Wszystkie"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: "Ulubione"),
              ],
            )
          : null,
    );
  }
}
