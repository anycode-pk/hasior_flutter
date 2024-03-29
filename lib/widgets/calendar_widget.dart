import 'package:flutter/material.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/screens/create_or_edit_event.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:intl/intl.dart';
import '../constants/language_constants.dart';
import '../models/calendar.dart';
import '../models/calendarList.dart';
import '../models/event.dart';
import '../models/userWithToken.dart';
import '../screens/event_detail_screen.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hasior_flutter/models/category.dart';

import '../theme.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget(
      {super.key,
      required this.isLoaded,
      required this.calendarList,
      required this.getData,
      required this.delete,
      required this.user,
      required this.categories,
      required this.isLoadedCategories});
  final bool isLoaded;
  final List<CalendarList> calendarList;
  final Future<void> Function([String? name]) getData;
  final bool delete;
  final UserWithToken? user;
  final List<Category> categories;
  final bool isLoadedCategories;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  final TextEditingController _searchController = TextEditingController();

  bool _isExpired(String eventTime) {
    DateTime date = DateTime.parse(eventTime);
    DateTime now = DateTime.now();
    return date.isBefore(now);
  }

  bool _isExpiredDate(String eventTime) {
    DateTime date = DateTime.parse(eventTime);
    DateTime now = DateTime.now();
    DateTime dateOnly = DateTime(now.year, now.month, now.day);
    return date.isBefore(dateOnly);
  }

  Future<void> _addFavouriteEvent(int id, int index) async {
    try {
      bool result = await ApiService().addFavouriteEvent(id);
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        GlobalSnackbar.successSnackbar(
            context, translation(context).added_to_favorites.capitalize());
        setState(() {
          widget.calendarList[index].event?.favorite = true;
        });
      }
    } on FormatException {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      GlobalSnackbar.errorSnackbar(context,
          translation(context).error_while_adding_to_favorites.capitalize());
    }
  }

  Future<void> _removeFavouriteEvent(int id, int index) async {
    try {
      bool result = await ApiService().deleteFavouriteEvent(id);
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        GlobalSnackbar.successSnackbar(
            context, translation(context).removed_from_favorites.capitalize());
        if (widget.calendarList.length > index) {
          setState(() {
            widget.calendarList[index].event?.favorite = false;
          });
        }
      }
    } on FormatException {
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
      for (int i = 0; i < widget.calendarList.length; i++) {
        if (widget.calendarList.length < 2 &&
            widget.calendarList[i].time != null) {
          widget.calendarList.removeAt(i);
        } else if (i == widget.calendarList.length - 1 &&
            widget.calendarList[i].time != null) {
          widget.calendarList.removeAt(i);
        } else if (widget.calendarList[i].time != null &&
            widget.calendarList[i + 1].time != null) {
          String time = widget.calendarList[index - 1].time ?? "";
          widget.calendarList.removeWhere((e) => e.time == time);
        }
      }
    });
  }

  void showAlertDialog(BuildContext context, Event event) {
    Widget cancelButton = TextButton(
      child: Text(translation(context).cancel.capitalize()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
        onPressed: () async {
          try {
            await ApiService().cancelEvent(event.id).then((value) {
              GlobalSnackbar.infoSnackbar(context,
                  translation(context).event_successfully_deleted.capitalize());
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            });
          } catch (e) {
            Navigator.pop(context);
            GlobalSnackbar.errorSnackbar(context,
                translation(context).error_while_deleting_event.capitalize());
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: Text(translation(context).delete.capitalize()));
    AlertDialog alert = AlertDialog(
      title: Text(translation(context).delete_event_question.capitalize()),
      content: Text(translation(context).confirm_deletion.capitalize()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.getData,
      child: Stack(
        children: <Widget>[
          ListView(),
          Visibility(
              visible: widget.isLoaded && widget.isLoadedCategories,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
              child: Center(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: TextField(
                        textInputAction: TextInputAction.search,
                        controller: _searchController,
                        onSubmitted: (value) {
                          widget.getData(value);
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          hintText:
                              "${translation(context).search.capitalize()}...",
                          hintStyle: const TextStyle(color: Colors.white),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                _searchController.clear();
                                widget.getData();
                              }
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
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
                          return buildListElement(
                              index, widget.calendarList[index]);
                        },
                        childCount: widget.calendarList.length + 1,
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget buildListElement(int index, CalendarList calendar) => Column(
        children: [
          (() {
            if (calendar.time != null) {
              return buildDate(calendar.time ?? "");
            } else {
              return buildCard(calendar.event!, index);
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
            style: TextStyle(
                fontSize: 20, color: _isExpiredDate(time) ? grayColor : null)),
      );

  Widget buildCard(Event event, int index) => Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          child: Dismissible(
            direction: widget.user != null
                ? widget.delete
                    ? DismissDirection.endToStart
                    : widget.calendarList[index].event?.favorite == false
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
                      _removeFavouriteEventFromList(index);
                      await _removeFavouriteEvent(event.id, index);
                    }
                  }
                : null,
            confirmDismiss: !widget.delete
                ? (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await _addFavouriteEvent(event.id, index);
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
                onLongPress: widget.user != null &&
                        widget.user!.isAdmin() &&
                        !_isExpired(event.eventTime)
                    ? () {
                        showModalBottomSheet<void>(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          builder: (BuildContext context) {
                            return SizedBox(
                                height: 200,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 6.0, bottom: 2.0, left: 20.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        event.name,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    const Divider(
                                      color: grayColor,
                                      thickness: 0.1,
                                      indent: 18,
                                      endIndent: 18,
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: Text(translation(context)
                                          .edit
                                          .capitalize()),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateOrEditEvent(
                                                      event: event)),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: Text(translation(context)
                                          .delete
                                          .capitalize()),
                                      onTap: () {
                                        showAlertDialog(context, event);
                                      },
                                    ),
                                  ],
                                ));
                          },
                        );
                      }
                    : null,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EventDetails(
                      event: event,
                      user: widget.user,
                      isExpired: _isExpired(event.eventTime),
                    );
                  }));
                },
                child: Container(
                    color: const Color.fromRGBO(49, 52, 57, 1),
                    width: double.infinity,
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              left: BorderSide(
                        color: grayColor,
                        width: 7.0,
                      ))),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: _isExpired(event.eventTime) ||
                                              event.isCanceled
                                          ? grayColor
                                          : null,
                                      decoration: event.isCanceled
                                          ? TextDecoration.lineThrough
                                          : null),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: widget.user != null
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
                                              backgroundColor: Color.fromRGBO(
                                                  0, 150, 136, 0.2),
                                              shadowColor: Colors.transparent,
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(15),
                                            ),
                                            child: const Icon(
                                              Icons.favorite,
                                              color: Color.fromRGBO(
                                                  0, 150, 136, 1),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () async {
                                              await _addFavouriteEvent(
                                                  event.id, index);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromRGBO(
                                                  0, 150, 136, 0.2),
                                              shadowColor: Colors.transparent,
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(15),
                                            ),
                                            child: const Icon(
                                              Icons.favorite_outline,
                                              color: Color.fromRGBO(
                                                  0, 150, 136, 1),
                                            ),
                                          )
                                    : Container(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
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
                              SizedBox(
                                width: 60,
                                child: Text(
                                  DateFormat.Hm(AppLocalizations.of(context)!
                                          .localeName)
                                      .format(DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                                          .parseUTC(event.eventTime)
                                          .toLocal()),
                                  style: const TextStyle(
                                      color: grayColor,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                                runSpacing: 1,
                                spacing: 5,
                                children: event.categories != null
                                    ? List.generate(event.categories!.length,
                                        (index) {
                                        return Chip(
                                          label: Text(
                                              "#${widget.categories.firstWhere((element) => element.id == event.categories![index]).name}"),
                                          backgroundColor: grayColor,
                                        );
                                      })
                                    : []),
                          )
                        ],
                      ),
                    ))),
          )));
}
