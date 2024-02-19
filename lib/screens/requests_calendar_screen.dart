import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/enums/decision.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/calendarRequests.dart';
import 'package:hasior_flutter/models/calendarRequestsList.dart';
import 'package:hasior_flutter/models/eventRequest.dart';
import 'package:hasior_flutter/screens/accepting_requests_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestsCalendar extends StatefulWidget {
  const RequestsCalendar({super.key});

  @override
  State<RequestsCalendar> createState() => _RequestsCalendarState();
}

class _RequestsCalendarState extends State<RequestsCalendar> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  final TextEditingController _searchController = TextEditingController();
  List<CalendarRequestsList> calendarReqestsList = [];

  Future<bool> _getData([String? name]) async {
    try {
      List<CalendarRequests>? dataEvents = await ApiService()
          .getAllUpcomingEventsForTicketRequest(name, Decision.NONE);
      if (dataEvents != null) {
        calendarReqestsList = [];
        for (CalendarRequests calendarRequest in dataEvents) {
          calendarReqestsList.add(
              CalendarRequestsList(time: calendarRequest.time, event: null));
          for (EventRequest eventRequest in calendarRequest.events) {
            calendarReqestsList
                .add(CalendarRequestsList(time: null, event: eventRequest));
          }
        }
      }
      return dataEvents != null;
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.errorSnackbar(
            context, translation(context).error_while_loading.capitalize());
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(translation(context).events_with_requests.capitalize()),
          centerTitle: true),
      body: OfflineBuilder(connectivityBuilder: (
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
      }, builder: (BuildContext context) {
        return FutureBuilder(
            future: _getData(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: _getData,
                  child: Stack(
                    children: <Widget>[
                      ListView(),
                      Center(
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              title: TextField(
                                textInputAction: TextInputAction.search,
                                controller: _searchController,
                                onSubmitted: (value) {
                                  _getData(value);
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  hintText:
                                      "${translation(context).search.capitalize()}...",
                                  hintStyle:
                                      const TextStyle(color: Colors.white),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      if (_searchController.text.isNotEmpty) {
                                        _searchController.clear();
                                        _getData();
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
                                  if (index == calendarReqestsList.length) {
                                    if (calendarReqestsList.isEmpty) {
                                      return Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            translation(context)
                                                .no_requests
                                                .capitalize(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: grayColor,
                                                fontSize: 20,
                                                fontStyle: FontStyle.italic),
                                          ));
                                    }
                                    return const SizedBox(
                                        height:
                                            kBottomNavigationBarHeight + 20);
                                  }
                                  return buildListElement(
                                      index, calendarReqestsList[index]);
                                },
                                childCount: calendarReqestsList.length + 1,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      }),
    );
  }

  Widget buildListElement(int index, CalendarRequestsList calendar) => Column(
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
            style: const TextStyle(fontSize: 20)),
      );

  Widget buildCard(EventRequest event, int index) => Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AcceptingRequests(id: event.id);
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
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            DateFormat.Hm(
                                    AppLocalizations.of(context)!.localeName)
                                .format(DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                                    .parseUTC(event.eventTime)
                                    .toLocal()),
                            style: const TextStyle(
                                color: grayColor, fontWeight: FontWeight.bold),
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
                                  transform:
                                      Matrix4.translationValues(-4.0, 0.0, 0.0),
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
                        ],
                      ),
                    ],
                  ),
                ))),
      ));
}
