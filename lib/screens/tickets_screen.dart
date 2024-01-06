import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/ticket.dart';
import 'package:hasior_flutter/screens/ticket_details_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Tickets extends StatefulWidget {
  const Tickets({super.key});

  @override
  State<Tickets> createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  List<Ticket> data = [];
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<bool> _getData() async {
    try {
      data = await ApiService().getTickets() ?? [];
      return true;
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
      return false;
    }
  }

  bool _isExpired(String eventTime) {
    DateTime date = DateTime.parse(eventTime);
    DateTime now = DateTime.now();
    return date.isBefore(now);
  }

  Widget buildCard(Ticket ticket, int index) => Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketDetails(
                          ticket: ticket,
                          isExpired: _isExpired(ticket.event.eventTime))),
                );
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
                                ticket.event.name,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: _isExpired(ticket.event.eventTime) ||
                                            ticket.isCanceled
                                        ? grayColor
                                        : null,
                                    decoration: ticket.isCanceled
                                        ? TextDecoration.lineThrough
                                        : null),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: grayColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${DateFormat.yMMMMEEEEd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(ticket.event.eventTime))} ${translation(context).at_hour} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(ticket.event.eventTime).toLocal())}",
                                      style: const TextStyle(
                                          color: grayColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translation(context).my_tickets.capitalize()),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _getData,
        child: Stack(
          children: <Widget>[
            ListView(),
            FutureBuilder(
                future: _getData(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            title: TextField(
                              textInputAction: TextInputAction.search,
                              controller: _searchController,
                              onSubmitted: (value) {},
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
                                if (index == data.length) {
                                  if (data.isEmpty) {
                                    return Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Text(
                                          translation(context)
                                              .no_tickets_available
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
                                return buildCard(data[index], index);
                              },
                              childCount: data.length + 1,
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
                })
          ],
        ),
      ),
    );
  }
}
