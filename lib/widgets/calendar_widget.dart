import 'package:flutter/material.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:intl/intl.dart';
import '../constants/language_constants.dart';
import '../models/calendar.dart';
import '../models/calendarList.dart';
import '../models/events.dart';
import '../models/userWithToken.dart';
import '../screens/event_detail_screen.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../theme.dart';

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
  final Future<void> Function([String? name]) getData;
  final bool delete;
  final UserWithToken? user;

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

  Future _addFavouriteEvent(int id, int index) async {
    try {
      bool result = await ApiService().addFavouriteEvent(id);
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        GlobalSnackbar.successSnackbar(
            context, translation(context).added_to_favorites.capitalize());
        setState(() {
          widget.calendarList[index].events?.favorite = true;
        });
      }
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      GlobalSnackbar.errorSnackbar(context,
          translation(context).error_while_adding_to_favorites.capitalize());
    }
  }

  Future _removeFavouriteEvent(int id, int index) async {
    try {
      bool result = await ApiService().deleteFavouriteEvent(id);
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        GlobalSnackbar.successSnackbar(
            context, translation(context).removed_from_favorites.capitalize());
        if (widget.calendarList.length >= index) {
          setState(() {
            widget.calendarList[index].events?.favorite = false;
          });
        }
      }
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      GlobalSnackbar.errorSnackbar(
          context,
          translation(context)
              .error_while_removing_from_favorites
              .capitalize());
    }
  }

  void _removeFavouriteEventFromList(int index) {
    setState(() {
      widget.calendarList.removeAt(index);
      for (var i = 0; i < widget.calendarList.length; i++) {
        if (widget.calendarList.length < 2 &&
            widget.calendarList[i].time != null) {
          widget.calendarList.removeAt(i);
        } else if (i == widget.calendarList.length - 1 &&
            widget.calendarList[i].time != null) {
          widget.calendarList.removeAt(i);
        } else if (widget.calendarList[i].time != null &&
            widget.calendarList[i + 1].time != null) {
          var time = widget.calendarList[index - 1].time ?? "";
          widget.calendarList.removeWhere((e) => e.time == time);
        }
      }
    });
  }

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
              //TODO: albo dodać czyszczenie, albo zmienić wyszukiwanie
              title: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  widget.getData(value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "${translation(context).search.capitalize()}...",
                    hintStyle: const TextStyle(color: Colors.white)),
              ),
              floating: true,
              automaticallyImplyLeading: false,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == widget.calendarList.length) {
                    if (widget.calendarList.isEmpty) {
                      return widget.delete
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                translation(context)
                                    .no_favorite_events
                                    .capitalize(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: grayColor,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic),
                              ))
                          : Container(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                translation(context)
                                    .no_upcoming_events
                                    .capitalize(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: grayColor,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic),
                              ));
                    }
                    return const SizedBox(
                        height: kBottomNavigationBarHeight + 20);
                  }
                  return buildList(index, widget.calendarList[index]);
                },
                childCount: widget.calendarList.length + 1,
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
            DateFormat.yMMMMEEEEd(AppLocalizations.of(context)!.localeName)
                .format(DateTime.parse(time))
                .toUpperCase(),
            style: const TextStyle(fontSize: 20)),
      );

  Widget buildCard(Events event, int index) => Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          child: Dismissible(
            direction: widget.user != null
                ? widget.delete
                    ? DismissDirection.endToStart
                    : widget.calendarList[index].events?.favorite == false
                        ? DismissDirection.startToEnd
                        : DismissDirection.none
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
                ? (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      _removeFavouriteEventFromList(index);
                      await _removeFavouriteEvent(event.id, index);
                    }
                  }
                : null,
            confirmDismiss: !widget.delete
                ? (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await _addFavouriteEvent(event.id, index);
                      // setState(() {
                      //   widget.calendarList[index] = widget.calendarList[index];
                      // });
                      return false;
                    }
                    return null;
                  }
                : null,
            child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EventDetails(
                      event: event,
                      user: widget.user,
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
                                DateFormat.Hm(AppLocalizations.of(context)!
                                        .localeName)
                                    .format(DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                                        .parseUTC(event.eventTime)
                                        .toLocal()),
                                style: const TextStyle(
                                    color: grayColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      transform: Matrix4.translationValues(
                                          -4.0, 0.0, 0.0),
                                      child: event.localization != null
                                          ? const Icon(
                                              Icons.location_pin,
                                              color: grayColor,
                                            )
                                          : const Icon(
                                              Icons.location_off,
                                              color: grayColor,
                                            ),
                                    ),
                                    Expanded(
                                      child: event.localization != null
                                          ? Text(event.localization ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: grayColor,
                                                  fontWeight: FontWeight.bold))
                                          : Text(
                                              translation(context)
                                                  .no_location_provided
                                                  .capitalize(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: grayColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic)),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              widget.user != null
                                  ? event.favorite
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            if (widget.delete) {
                                              _removeFavouriteEventFromList(
                                                  index);
                                            }
                                            await _removeFavouriteEvent(
                                                event.id, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(15),
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color:
                                                Color.fromRGBO(0, 150, 136, 1),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () async {
                                            await _addFavouriteEvent(
                                                event.id, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(15),
                                          ),
                                          child: const Icon(
                                            Icons.favorite_outline,
                                            color:
                                                Color.fromRGBO(0, 150, 136, 1),
                                          ),
                                        )
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                    ))),
          )));
}
