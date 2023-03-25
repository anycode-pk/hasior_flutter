import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar.dart';
import '../models/calendarList.dart';
import '../models/events.dart';
import '../models/user.dart';
import '../screens/event_detail_screen.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget(
      {super.key,
      required this.isLoaded,
      required this.calendarList,
      required this.dataEvents,
      required this.getData,
      required this.delete,
      required this.user});
  final bool isLoaded;
  final List<CalendarList> calendarList;
  final List<Calendar>? dataEvents;
  final Future<void> Function() getData;
  final bool delete;
  final User? user;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);

  // Future _getData() async {
  //   widget.dataEvents = await ApiService().getFavouriteEvents();
  //   widget.calendarList = [];
  //   if (widget.dataEvents != null) {
  //     widget.dataEvents?.forEach((element) {
  //       widget.calendarList.add(CalendarList(time: element.time, events: null));
  //       for (var element in element.events) {
  //         widget.calendarList.add(CalendarList(time: null, events: element));
  //       }
  //     });
  //     setState(() {
  //       widget.isLoaded = true;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isLoaded,
      replacement: const Center(
        child: CircularProgressIndicator(),
      ),
      child: Center(
          child: RefreshIndicator(
        onRefresh: widget.getData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: TextField(
                onChanged: (value) {
                  //_filter(value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "Wyszukaj...",
                    hintStyle: TextStyle(color: Colors.white)),
              ),
              floating: true,
              automaticallyImplyLeading: false,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return buildList(index, widget.calendarList[index]);
                },
                childCount: widget.calendarList.length,
              ),
            )
          ],
        ),
      )
          // ListView.separated(
          //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          //     itemCount: widget.filteredCalendarList.length,
          //     separatorBuilder: (context, index) {
          //       return const SizedBox(height: 12);
          //     },
          //     itemBuilder: (context, index) {
          //       widget.calendarList;
          //       widget.dataEvents;
          //       return buildList(index, widget.filteredCalendarList[index]);
          //     }),
          ),
    );
  }

  Widget buildList(int index, CalendarList calendar) => Column(
        children: [
          (() {
            if (calendar.time != null) {
              return buildDate(calendar.time ?? "");
            } else {
              return buildCard(calendar.events!, index);
            }
          }()),
        ],
      );

  Widget buildDate(String time) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
        width: double.infinity,
        child: Text(
            DateFormat.yMMMMEEEEd("pl_PL")
                .format(DateTime.parse(time))
                .toUpperCase(),
            style: const TextStyle(fontSize: 20)),
      );

  Widget buildCard(Events event, int index) => Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Dismissible(
        direction: widget.user != null
            ? widget.delete
                ? DismissDirection.endToStart
                : DismissDirection.startToEnd
            : DismissDirection.none,
        key: UniqueKey(),
        background: Container(
          color: Colors.green,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.favorite),
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.delete),
            ),
          ),
        ),
        onDismissed: widget.delete
            ? (direction) {
                if (direction == DismissDirection.endToStart) {
                  const snackBar = SnackBar(
                    content: Text(
                      "Usunięto z ulubionych",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    var time = "";
                    if (widget.calendarList[index - 1].time != null &&
                        index == widget.calendarList.length - 1) {
                      time = widget.calendarList[index - 1].time ?? "";
                      widget.calendarList.removeAt(index);
                      widget.calendarList.removeWhere((e) => e.time == time);
                    } else if (widget.calendarList[index - 1].time != null &&
                        widget.calendarList[index + 1].time != null) {
                      time = widget.calendarList[index - 1].time ?? "";
                      widget.calendarList.removeAt(index);
                      widget.calendarList.removeWhere((e) => e.time == time);
                    }
                  });
                }
              }
            : null,
        confirmDismiss: !widget.delete
            ? (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  const snackBar = SnackBar(
                    content: Text(
                      "Dodano do ulubionych",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  // setState(() {
                  //   widget.calendarList[index] = widget.calendarList[index];
                  // });
                  return false;
                }
              }
            : null,
        child: InkWell(
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
                          const Icon(
                            Icons.favorite,
                            color: Color.fromRGBO(0, 150, 136, 1),
                          )
                        ],
                      ),
                    ],
                  ),
                ))),
      ));
}
