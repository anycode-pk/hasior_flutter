import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/validateTicket.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanResult extends StatefulWidget {
  final String code;
  const ScanResult({super.key, required this.code});

  @override
  State<ScanResult> createState() => _ScanResultState();
}

class _ScanResultState extends State<ScanResult> {
  ValidateTicket? ticket;
  TextStyle styleHeader =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  TextStyle styleLine = const TextStyle(fontSize: 20);

  Future<bool> _getData(String token) async {
    try {
      ticket = await ApiService().validateTicket(token);
      return ticket != null;
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.errorSnackbar(context,
            translation(context).error_occurred_during_validation.capitalize());
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, true),
        ),
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
        return FutureBuilder(
            future: _getData(widget.code),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (ticket != null && ticket!.ticket != null) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            ticket!.isCorrect
                                ? translation(context).ticket_valid.capitalize()
                                : translation(context)
                                    .ticket_invalid
                                    .capitalize(),
                            style: TextStyle(
                                fontSize: 30,
                                color: ticket!.isCorrect
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text("${translation(context).event_name.capitalize()}:",
                            style: styleHeader),
                        Text(ticket!.ticket!.event.name, style: styleLine),
                        const Divider(),
                        Text("${translation(context).event_date.capitalize()}:",
                            style: styleHeader),
                        Text(
                            "${DateFormat.yMMMMEEEEd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(ticket!.ticket!.event.eventTime))} ${translation(context).at_hour} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(ticket!.ticket!.event.eventTime).toLocal())}",
                            style: styleLine),
                        const Divider(),
                        Text("${translation(context).owner.capitalize()}:",
                            style: styleHeader),
                        Text(ticket!.ticket!.owner.email, style: styleLine),
                        const Divider(),
                        Text("${translation(context).created_at.capitalize()}:",
                            style: styleHeader),
                        Text(
                            "${DateFormat.yMMMMEEEEd(AppLocalizations.of(context)!.localeName).format(DateTime.parse(ticket!.ticket!.createdAt))} ${translation(context).at_hour} ${DateFormat.Hm(AppLocalizations.of(context)!.localeName).format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(ticket!.ticket!.createdAt).toLocal())}",
                            style: styleLine),
                        const Divider(),
                        Text(
                            "${translation(context).has_it_been_cancelled.capitalize()}:",
                            style: styleHeader),
                        Text(
                            ticket!.ticket!.isCanceled
                                ? translation(context).yes.capitalize()
                                : translation(context).no.capitalize(),
                            style: styleLine),
                      ],
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.center,
                  child: Text(
                    translation(context).ticket_not_found.capitalize(),
                    style: const TextStyle(fontSize: 30, color: Colors.red),
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
}
