import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/classes/string_empty.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/enums/decision.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/ticketRequest.dart';
import 'package:hasior_flutter/models/ticketRequestDecision.dart';
import 'package:hasior_flutter/models/ticketRequestWithSelect.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';

class AcceptingRequests extends StatefulWidget {
  final int id;
  const AcceptingRequests({super.key, required this.id});

  @override
  State<AcceptingRequests> createState() => _AcceptingRequestsState();
}

class _AcceptingRequestsState extends State<AcceptingRequests> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  List<TicketRequestWithSelect> ticketRequestsWithSelect = [];
  List<TicketRequest> selectedTicketRequests = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      setState(() {
        isLoaded = false;
      });
      List<TicketRequest>? ticketRequests =
          await ApiService().getAllEventTicketRequests(widget.id);
      if (ticketRequests != null) {
        setState(() {
          ticketRequestsWithSelect = [];
          selectedTicketRequests = [];
        });
        for (TicketRequest ticketRequest in ticketRequests) {
          if (ticketRequest.status == Decision.NONE) {
            ticketRequestsWithSelect.add(TicketRequestWithSelect(
                ticketRequest: ticketRequest, isSelected: false));
          }
        }
      }
      setState(() {
        isLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.errorSnackbar(
            context, translation(context).error_while_loading.capitalize());
      }
    }
  }

  Future<void> _decisionRequests(Decision decision) async {
    try {
      List<TicketRequestDecision> ticketRequestDecision = [];
      for (TicketRequest ticketRequest in selectedTicketRequests) {
        {
          ticketRequestDecision.add(TicketRequestDecision(
              ticketRequestId: ticketRequest.id,
              description: StringEmpty().empty(),
              status: decision));
        }
      }
      List<TicketRequest>? response =
          await ApiService().ticketRequestDecision(ticketRequestDecision);
      if (response != null) {
        await _getData();
        if (mounted) {
          GlobalSnackbar.successSnackbar(context,
              translation(context).requests_successfully_accepted.capitalize());
        }
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.errorSnackbar(context,
            translation(context).error_while_accepting_requests.capitalize());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(translation(context).accepting_requests.capitalize()),
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
        return Visibility(
            visible: isLoaded,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: CustomScrollView(slivers: [
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == ticketRequestsWithSelect.length) {
                    return Container(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          translation(context).no_requests.capitalize(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: grayColor,
                              fontSize: 20,
                              fontStyle: FontStyle.italic),
                        ));
                  }
                  return buildCard(index, ticketRequestsWithSelect[index]);
                },
                childCount: ticketRequestsWithSelect.length,
              ))
            ]));
      }),
      bottomNavigationBar: selectedTicketRequests.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                height: 40,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          icon: Container(),
                          onPressed: () => _decisionRequests(Decision.ACCEPT),
                          label: Text(
                              "${translation(context).accept.capitalize()} (${selectedTicketRequests.length})"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          )),
                      ElevatedButton.icon(
                          icon: Container(),
                          onPressed: () => _decisionRequests(Decision.REJECT),
                          label: Text(
                              "${translation(context).reject.capitalize()} (${selectedTicketRequests.length})"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          )),
                    ]),
              ))
          : null,
    );
  }

  Widget buildCard(
          int index, TicketRequestWithSelect ticketRequestWithSelect) =>
      Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      ticketRequestsWithSelect[index].isSelected =
                          !ticketRequestWithSelect.isSelected;
                      if (ticketRequestsWithSelect[index].isSelected == true) {
                        selectedTicketRequests
                            .add(ticketRequestsWithSelect[index].ticketRequest);
                      } else {
                        selectedTicketRequests.removeWhere(
                            (selectedTicketRequest) =>
                                selectedTicketRequest.id ==
                                ticketRequestsWithSelect[index]
                                    .ticketRequest
                                    .id);
                      }
                    });
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
                                    ticketRequestWithSelect
                                        .ticketRequest.owner.email,
                                    style: const TextStyle(fontSize: 20),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ticketRequestWithSelect.isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: Color.fromRGBO(0, 150, 136, 1))
                                    : const Icon(
                                        Icons.circle_outlined,
                                        color: grayColor,
                                      )
                              ],
                            ),
                          ],
                        ),
                      )))));
}
