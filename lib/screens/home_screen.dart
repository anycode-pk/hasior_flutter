import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/widgets/calendar_widget.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import '../constants/language_constants.dart';
import '../models/calendarList.dart';
import '../models/calendar.dart';
import '../models/userWithToken.dart';
import '../widgets/navigator_drawer.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'create_or_edit_event.dart';

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
  // bool isSearching = false;
  int currentIndex = 0;
  bool isLoading = false;
  bool isLoadingFavourite = false;
  UserWithToken? user;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _getUser();
    _getEvents();
    _getFavouriteEvents();
  }

  Future<bool> _getUser() async {
    user = await ApiService().userFromSharedPreferences();
    return user != null;
  }

  Future<void> _getEvents([String? name]) async {
    try {
      if (user != null) {
        dataEvents = await ApiService().getAllUpcomingEventsForUser(name);
      } else {
        dataEvents = await ApiService().getAllUpcomingEvents(name);
      }
      if (dataEvents != null) {
        calendarList = [];
        dataEvents?.forEach((element) {
          calendarList.add(CalendarList(time: element.time, event: null));
          for (var element in element.events) {
            calendarList.add(CalendarList(time: null, event: element));
          }
        });
        setState(() {
          isLoading = true;
        });
      }
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  Future<void> _getFavouriteEvents([String? name]) async {
    try {
      if (user != null) {
        favouriteEvents = await ApiService().getFavouriteEvents(name);
        if (favouriteEvents != null) {
          calendarListFavourite = [];
          favouriteEvents?.forEach((element) {
            calendarListFavourite
                .add(CalendarList(time: element.time, event: null));
            for (var element in element.events) {
              calendarListFavourite
                  .add(CalendarList(time: null, event: element));
            }
          });
          setState(() {
            isLoadingFavourite = true;
          });
        }
      }
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      CalendarWidget(
        isLoading: isLoading,
        calendarList: calendarList,
        dataEvents: dataEvents,
        getData: _getEvents,
        delete: false,
        user: user,
      ),
      CalendarWidget(
        isLoading: isLoadingFavourite,
        calendarList: calendarListFavourite,
        dataEvents: favouriteEvents,
        getData: _getFavouriteEvents,
        delete: true,
        user: user,
      )
    ];
    return FutureBuilder(
        future: _getUser(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(translation(context).event_calendar.capitalize()),
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
              extendBody: true,
              body: OfflineBuilder(
                connectivityBuilder: (
                  BuildContext context,
                  ConnectivityResult connectivity,
                  Widget child,
                ) {
                  if (connectivity == ConnectivityResult.none) {
                    return OfflineWidget(
                      child: child,
                    );
                  } else {
                    return child;
                  }
                },
                builder: (BuildContext context) {
                  return user != null
                      ? PageView(
                          controller: _pageController,
                          onPageChanged: (newIndex) {
                            setState(() {
                              if (currentIndex != newIndex) {
                                _getEvents();
                                _getFavouriteEvents();
                              }
                              currentIndex = newIndex;
                            });
                          },
                          children: screens,
                        )
                      : screens[0];
                },
              ),
              floatingActionButton: user != null && user!.isAdmin()
                  ? FloatingActionButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateOrEditEvent()),
                        );
                        if (result != null) {
                          _getEvents();
                        }
                      },
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.add),
                    )
                  : null,
              bottomNavigationBar: user != null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            primaryBlack.withOpacity(0.4)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 1.0],
                          tileMode: TileMode.clamp,
                        ),
                      ),
                      child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 10, left: 10, right: 10),
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            color: primaryBlack,
                          ),
                          child: BottomNavigationBar(
                            backgroundColor: Colors.transparent,
                            currentIndex: currentIndex,
                            onTap: (index) {
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                            items: [
                              BottomNavigationBarItem(
                                  icon: const Icon(Icons.calendar_month),
                                  label: translation(context)
                                      .all_events
                                      .capitalize()),
                              BottomNavigationBarItem(
                                  icon: const Icon(Icons.favorite),
                                  label: translation(context)
                                      .favorite_events
                                      .capitalize()),
                            ],
                          )),
                    )
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
