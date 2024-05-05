import 'dart:convert';

import 'package:hasior_flutter/enums/decision.dart';

List<TicketRequestDecision> ticketRequestDecisionFromJson(String str) =>
    List<TicketRequestDecision>.from(
        json.decode(str).map((x) => TicketRequestDecision.fromJson(x)));

String ticketRequestDecisionToJson(List<TicketRequestDecision> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketRequestDecision {
  int ticketRequestId;
  String description;
  Decision status;

  TicketRequestDecision({
    required this.ticketRequestId,
    required this.description,
    required this.status,
  });

  factory TicketRequestDecision.fromJson(Map<String, dynamic> json) =>
      TicketRequestDecision(
        ticketRequestId: json["ticketRequestId"],
        description: json["description"],
        status: Decision.fromValue(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "ticketRequestId": ticketRequestId,
        "description": description,
        "status": status.value,
      };
}
