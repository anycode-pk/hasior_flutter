import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/events.dart';
import '../models/calendarList.dart';
import '../models/calendar.dart';
import '../widgets/navigator_drawer.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'event_detail_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  //List<Calendar>? data;
  List<Calendar>? dataEvents;
  List<CalendarList> calendarList = [];
  List<Calendar>? filteredDataEvents;
  List<CalendarList> filteredCalendarList = [];
  bool isSearching = false;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future _getData() async {
    //data = await ApiService().getCalendar();
    dataEvents = await ApiService().getCalendarEvents();
    calendarList = [];
    if (/*data != null &&*/ dataEvents != null) {
      //filteredDataEvents = dataEvents;
      dataEvents?.forEach((element) {
        calendarList.add(CalendarList(time: element.time, events: null));
        for (var element in element.events) {
          calendarList.add(CalendarList(time: null, events: element));
        }
      });
      filteredCalendarList = calendarList;
      setState(() {
        isLoaded = true;
      });
    }
  }

  void _filter(value) {
    setState(() {
      // tutaj nie działa filtrowanie
      filteredDataEvents = dataEvents!
          .where((event) => event.events.any((element) => element.name
              .toLowerCase()
              .contains(value.toString().toLowerCase())))
          .toList();
      filteredCalendarList = [];
      filteredDataEvents?.forEach((element) {
        filteredCalendarList
            .add(CalendarList(time: element.time, events: null));
        for (var element in element.events) {
          filteredCalendarList.add(CalendarList(time: null, events: element));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: !isSearching
              ? Text(widget.title)
              : TextField(
                  onChanged: (value) {
                    _filter(value);
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      hintText: "Wyszukaj...",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
          actions: !isSearching
              ? [
                  // Navigate to the Search Screen
                  IconButton(
                      onPressed: () => {
                            setState(() {
                              isSearching = true;
                            })
                          },
                      icon: const Icon(Icons.search))
                ]
              : [
                  IconButton(
                      onPressed: () => {
                            setState(() {
                              isSearching = false;
                              filteredCalendarList = calendarList;
                            })
                          },
                      icon: const Icon(Icons.clear))
                ],
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: drawerColor,
          ),
          child: const MenuNavigationDrawer(),
        ),
        body: Visibility(
          visible: isLoaded,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: Center(
              child: RefreshIndicator(
            onRefresh: _getData,
            child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                itemCount: filteredCalendarList.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  calendarList;
                  dataEvents;
                  return buildList(index, filteredCalendarList[index]);
                }),
          )),
        ));
  }

  Widget buildList(int index, CalendarList calendar) => Column(
        children: [
          (() {
            if (calendar.time != null) {
              return buildDate(calendar.time ?? "");
            } else {
              return buildCard(calendar.events!);
            }
          }()),
        ],
      );

  Widget buildDate(String time) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Text(
            DateFormat.yMMMMEEEEd("pl_PL")
                .format(DateTime.parse(time))
                .toUpperCase(),
            style: const TextStyle(fontSize: 20)),
      );

  Widget buildCard(Events event) => InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return EventDetails(
            event: event,
          );
        }));
      },
      child: Container(
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
                        event.name,
                        style: const TextStyle(fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      DateFormat.Hm("pl_PL").format(
                          DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                              .parseUTC(event.eventTime)
                              .toLocal()),
                      style: const TextStyle(
                          color: grayColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            transform:
                                Matrix4.translationValues(-4.0, 0.0, 0.0),
                            child: const Icon(
                              Icons.location_pin,
                              color: grayColor,
                            ),
                          ),
                          Expanded(
                            child: Text(event.localization,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: grayColor,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: const [
                        Text("Uczestniczysz",
                            style: TextStyle(
                                color: Color.fromRGBO(0, 150, 136, 1),
                                fontWeight: FontWeight.bold)),
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
          )));
}
