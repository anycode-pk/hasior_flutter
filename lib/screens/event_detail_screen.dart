import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/enums/role.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:hasior_flutter/screens/create_or_edit_event.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../classes/currency.dart';
import '../constants/language_constants.dart';
import '../models/events.dart';

class EventDetails extends StatefulWidget {
  final Events event;
  final UserWithToken? user;

  const EventDetails({super.key, required this.event, required this.user});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  NumberFormat currencyFormat = Currency().getPLN();
  bool isLoaded = false;
  Image? eventImage;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future _getData() async {
    try {
      File? file = await ApiService().getFileByEventId(widget.event.id);
      if (file != null) {
        eventImage = Image.file(file);
      }
      setState(() {
        isLoaded = true;
      });
    } catch (e) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  bool _isAdmin() {
    if (widget.user == null) {
      return false;
    }
    return widget.user!.roles.contains(Role.ADMIN);
  }

  Future _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
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
            await ApiService().deleteEvent(widget.event.id).then((value) {
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
    return Scaffold(
        appBar: AppBar(
          title: Text(translation(context).detailed_view.capitalize()),
          centerTitle: true,
          actions: _isAdmin()
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
        body: Visibility(
            visible: isLoaded,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: CustomScrollView(slivers: [
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
                                  color: const Color.fromRGBO(49, 52, 57, 1),
                                  width: double.infinity,
                                  height: 180,
                                  margin: const EdgeInsets.only(top: 200),
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                widget.event.name,
                                                style: const TextStyle(
                                                    fontSize: 20),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                          child: const Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: grayColor,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                          child: widget.event
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
                                                          child: widget.event.localization !=
                                                                  null
                                                              ? Text(widget.event.localization ?? "",
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          grayColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))
                                                              : Text(
                                                                  translation(context)
                                                                      .no_location_provided
                                                                      .capitalize(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          grayColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontStyle:
                                                                          FontStyle.italic)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                          child: const Icon(
                                                            Icons.sell,
                                                            color: grayColor,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                              currencyFormat
                                                                  .format(widget
                                                                          .event
                                                                          .price ??
                                                                      0),
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
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: eventImage?.image ??
                                        const AssetImage("assets/logo.png"),
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
                              ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            child: ElevatedButton(
                                onPressed: () {
                                  if (widget.event.ticketsLink != null) {
                                    _launchURL(widget.event.ticketsLink ?? "");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20)),
                                child: Text(translation(context)
                                    .go_to_event_page
                                    .capitalize())),
                          )
                        : Container(),
                  ],
                ),
              ),
            ])));
  }
}
