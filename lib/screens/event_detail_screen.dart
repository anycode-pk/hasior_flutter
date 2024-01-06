import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/ticketRequest.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:hasior_flutter/screens/create_or_edit_event.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../classes/currency.dart';
import '../constants/language_constants.dart';
import '../models/event.dart';

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

  @override
  void initState() {
    super.initState();
    _getTicketRequests();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _getTicketRequests() async {
    try {
      dataTicketRequest = await ApiService().getTicketRequests();
      return true;
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
      return false;
    }
  }

  bool _isTicketRequest() {
    return dataTicketRequest
        .where((element) => element.event.id == widget.event.id)
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
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Expanded(
            child: QrImage(
          data: "1234567980",
          size: 200,
        ));
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
        appBar: AppBar(
          title: Text(translation(context).detailed_view.capitalize()),
          centerTitle: true,
          actions:
              widget.user != null && widget.user!.isAdmin() && !widget.isExpired
                  ? [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CreateOrEditEvent(event: widget.event)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showAlertDialog(context);
                        },
                      ),
                    ]
                  : null,
        ),
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
                future: _getTicketRequests(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return CustomScrollView(slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(10.0)),
                                child: SizedBox(
                                  height: 380,
                                  child: Stack(
                                    children: [
                                      Container(
                                          color: const Color.fromRGBO(
                                              49, 52, 57, 1),
                                          width: double.infinity,
                                          height: 180,
                                          margin:
                                              const EdgeInsets.only(top: 200),
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
                                                            overflow:
                                                                TextOverflow
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
                                                              .symmetric(
                                                          vertical: 3),
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
                                                                  child:
                                                                      const Icon(
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
                                                                              FontWeight.bold)),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 3),
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
                                                                          overflow: TextOverflow
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
                                                                          overflow: TextOverflow
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
                                                              .symmetric(
                                                          vertical: 3),
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
                                                                  child:
                                                                      const Icon(
                                                                    Icons.sell,
                                                                    color:
                                                                        grayColor,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                      _priceFormat(widget
                                                                          .event
                                                                          .price),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              grayColor,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
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
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: widget.event.thumbnail !=
                                                    null
                                                ? Image.network(widget
                                                        .event.thumbnail!.path)
                                                    .image
                                                : const AssetImage(
                                                    "assets/logo.png"),
                                            fit: BoxFit.cover,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.25),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        height: 200,
                                        width: double.infinity,
                                        child: null,
                                      ),
                                    ],
                                  ),
                                )),
                            Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: widget.event.description != null
                                      ? Text(
                                          widget.event.description ?? "",
                                          style:
                                              const TextStyle(color: grayColor),
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
                                          if (widget.event.ticketsLink !=
                                              null) {
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
                            Container(
                                padding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                      onPressed: _isTicketRequest()
                                          ? null
                                          : () => _sendRequestForTicket(
                                              widget.event.id),
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
                                          : Text(_isTicketRequest()
                                              ? translation(context)
                                                  .ticket_request_has_been_sent
                                                  .capitalize()
                                              : translation(context)
                                                  .ask_for_a_ticket
                                                  .capitalize())),
                                ))
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
