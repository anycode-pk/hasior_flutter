import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/enums/decision.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/ticket.dart';
import 'package:hasior_flutter/models/ticketRequest.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:hasior_flutter/screens/create_or_edit_event.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:hasior_flutter/screens/ticket_details_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../classes/currency.dart';
import '../constants/language_constants.dart';
import '../models/event.dart';
import '../theme.dart';

class EventDetails extends StatefulWidget {
  final Event event;
  final UserWithToken? user;
  final bool isExpired;
  const EventDetails(
      {super.key,
      required this.event,
      required this.user,
      required this.isExpired});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  NumberFormat currencyFormat = Currency().getPLN();
  bool isLoading = false;
  List<TicketRequest> dataTicketRequest = [];
  List<Ticket> dataTicket = [];
  bool isRequestButtonDisabled = false;
  String requestButtonText = "";

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _isExpired(String eventTime) {
    DateTime date = DateTime.parse(eventTime);
    DateTime now = DateTime.now();
    return date.isBefore(now);
  }

  Future<bool> _getData() async {
    try {
      if (widget.user == null) {
        return true;
      }
      dataTicketRequest = await ApiService().getTicketRequests() ?? [];
      dataTicket = await ApiService().getTicketsFromSharedPreferences() ?? [];
      _setRequestButtonText();
      return true;
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
      return false;
    }
  }

  Future<void> _navigateToTicketDetailsScreen() async {
    Ticket ticket =
        dataTicket.firstWhere((ticket) => ticket.event.id == widget.event.id);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TicketDetails(
              ticket: ticket, isExpired: _isExpired(ticket.event.eventTime))),
    );
  }

  Future<void> _requestButtonAction() async {
    if (_isTicketRequest(Decision.ACCEPT) && _isTicket()) {
      await _navigateToTicketDetailsScreen();
    } else if (_isTicketRequest(Decision.ACCEPT) && !_isTicket()) {
      setState(() {
        isLoading = true;
      });
      await ApiService().getTickets();
      setState(() {
        isLoading = false;
      });
    } else {
      await _sendRequestForTicket(widget.event.id);
    }
  }

  void _setRequestButtonText() {
    if (_isTicketRequest(Decision.NONE)) {
      isRequestButtonDisabled = true;
      requestButtonText =
          translation(context).ticket_request_has_been_sent.capitalize();
    } else if (_isTicketRequest(Decision.ACCEPT) && _isTicket()) {
      isRequestButtonDisabled = false;
      requestButtonText = translation(context).show_ticket.capitalize();
    } else if (_isTicketRequest(Decision.ACCEPT) && !_isTicket()) {
      isRequestButtonDisabled = false;
      requestButtonText = translation(context).download_ticket.capitalize();
    } else if (_isTicketRequest(Decision.REJECT)) {
      isRequestButtonDisabled = true;
      requestButtonText =
          translation(context).ticket_request_denied.capitalize();
    } else {
      isRequestButtonDisabled = false;
      requestButtonText = translation(context).ask_for_a_ticket.capitalize();
    }
  }

  bool _isTicketRequest(Decision decision) {
    return dataTicketRequest
        .where((ticketRequest) =>
            ticketRequest.event.id == widget.event.id &&
            ticketRequest.status == decision)
        .isNotEmpty;
  }

  bool _isTicket() {
    return dataTicket
        .where((ticket) => ticket.event.id == widget.event.id)
        .isNotEmpty;
  }

  Future<void> _sendRequestForTicket(int id) async {
    try {
      setState(() {
        isLoading = true;
      });
      bool response = await ApiService().sendRequestForTicket(id);
      if (response && context.mounted) {
        GlobalSnackbar.successSnackbar(
            context,
            translation(context)
                .your_ticket_request_has_been_successfully_submitted
                .capitalize());
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      GlobalSnackbar.errorSnackbar(context,
          translation(context).failed_to_send_ticket_request.capitalize());
      setState(() {
        isLoading = false;
      });
    }
  }

  String _priceFormat(double? price) {
    if (price == null || price == 0) {
      return translation(context).free.capitalize();
    }
    return currencyFormat.format(price);
  }

  void showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(translation(context).cancel.capitalize()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
        onPressed: () async {
          try {
            await ApiService().cancelEvent(widget.event.id).then((value) {
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

  Widget _showEventStatus() {
    String text = "";
    if (widget.isExpired) {
      text =
          translation(context).deadline_for_this_event_has_passed.capitalize();
    } else if (widget.event.isCanceled) {
      text = translation(context).event_has_been_canceled.capitalize();
    }
    return text.isNotEmpty
        ? Row(
            children: [
              Expanded(
                  child: Text(text,
                      style: const TextStyle(
                          color: grayColor, fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis)),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        return FutureBuilder(
            future: _getData(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return CustomScrollView(slivers: [
                  SliverAppBar(
                    toolbarHeight: 65,
                    leading: Container(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: CircleAvatar(
                            backgroundColor: primarycolor,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                            ))),
                    flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: widget.event.images != null &&
                                      widget.event.images!.isNotEmpty
                                  ? Image.network(
                                          widget.event.images!.first.path)
                                      .image
                                  : const AssetImage("assets/logo.png"),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          height: 200,
                          width: double.infinity,
                          child: null,
                        )
                      ],
                    )),
                    expandedHeight: 200,
                    actions: widget.user != null &&
                            widget.user!.isAdmin() &&
                            !widget.isExpired
                        ? [
                            Container(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: primarycolor,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.black,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateOrEditEvent(
                                                      event: widget.event)),
                                        );
                                      },
                                    ))),
                            Container(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: primarycolor,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.black,
                                      onPressed: () {
                                        showAlertDialog(context);
                                      },
                                    ))),
                          ]
                        : null,
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10.0)),
                            child: SizedBox(
                              height: 180,
                              child: Stack(
                                children: [
                                  Container(
                                      color:
                                          const Color.fromRGBO(49, 52, 57, 1),
                                      width: double.infinity,
                                      height: 180,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                          color: grayColor,
                                          width: 7.0,
                                        ))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        widget.event.name,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            decoration: widget
                                                                    .event
                                                                    .isCanceled
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : null),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                _showEventStatus(),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              transform: Matrix4
                                                                  .translationValues(
                                                                      -4.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: const Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                color:
                                                                    grayColor,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  "${DateFormat.yMMMMEEEEd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(widget.event.eventTime))} ${translation(context).at_hour} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(widget.event.eventTime).toLocal())}",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          grayColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              transform: Matrix4
                                                                  .translationValues(
                                                                      -4.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: widget
                                                                          .event
                                                                          .localization !=
                                                                      null
                                                                  ? const Icon(
                                                                      Icons
                                                                          .location_pin,
                                                                      color:
                                                                          grayColor,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .location_off,
                                                                      color:
                                                                          grayColor,
                                                                    ),
                                                            ),
                                                            Expanded(
                                                              child: widget
                                                                          .event
                                                                          .localization !=
                                                                      null
                                                                  ? Text(
                                                                      widget.event.localization ??
                                                                          "",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              grayColor,
                                                                          fontWeight: FontWeight
                                                                              .bold))
                                                                  : Text(
                                                                      translation(context)
                                                                          .no_location_provided
                                                                          .capitalize(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              transform: Matrix4
                                                                  .translationValues(
                                                                      -4.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: const Icon(
                                                                Icons.sell,
                                                                color:
                                                                    grayColor,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  _priceFormat(
                                                                      widget
                                                                          .event
                                                                          .price),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          grayColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            )),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.format_quote,
                                    size: 40,
                                  ),
                                  Expanded(
                                    child: Text(
                                        "${translation(context).event_description.capitalize()}:",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: widget.event.description != null
                                  ? Text(
                                      widget.event.description ?? "",
                                      style: const TextStyle(color: grayColor),
                                    )
                                  : Text(
                                      translation(context)
                                          .no_event_description
                                          .capitalize(),
                                      style: const TextStyle(
                                          color: grayColor,
                                          fontStyle: FontStyle.italic)),
                            )
                          ],
                        ),
                        const Spacer(),
                        widget.event.ticketsLink != null
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                child: TextButton(
                                    onPressed: () {
                                      if (widget.event.ticketsLink != null) {
                                        _launchURL(
                                            widget.event.ticketsLink ?? "");
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(20),
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: Colors.white)),
                                    child: Text(translation(context)
                                        .go_to_event_page
                                        .capitalize())),
                              )
                            : Container(),
                        widget.user != null
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                      onPressed: isRequestButtonDisabled
                                          ? null
                                          : _requestButtonAction,
                                      icon: isLoading
                                          ? Container(
                                              width: 24,
                                              height: 24,
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Container(),
                                      label: isLoading
                                          ? const Text("")
                                          : Text(requestButtonText)),
                                ))
                            : Container()
                      ],
                    ),
                  ),
                ]);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      },
    ));
  }
}
