import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/ticket.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TicketDetails extends StatefulWidget {
  final Ticket ticket;
  final bool isExpired;
  const TicketDetails(
      {super.key, required this.ticket, required this.isExpired});

  @override
  State<TicketDetails> createState() => _TicketDetailsState();
}

class _TicketDetailsState extends State<TicketDetails> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(translation(context).ticket_details.capitalize()),
          centerTitle: true,
        ),
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
          return CustomScrollView(slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        child: QrImage(
                          data: widget.ticket.uniqeId,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      child: Container(
                        color: const Color.fromRGBO(49, 52, 57, 1),
                        width: double.infinity,
                        height: 90,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.ticket.event.name,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: widget.isExpired ||
                                                  widget.ticket.isCanceled
                                              ? grayColor
                                              : null,
                                          decoration: widget.ticket.isCanceled
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
                                            "${DateFormat.yMMMMEEEEd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(widget.ticket.event.eventTime))} ${translation(context).at_hour} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(widget.ticket.event.eventTime).toLocal())}",
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
                        ),
                      ))
                ]),
              ),
            )
          ]);
        }));
  }
}
