import 'dart:convert';

import 'package:hasior_flutter/enums/decision.dart';
import 'package:hasior_flutter/models/ticketEvent.dart';
import 'package:hasior_flutter/models/ticketOwner.dart';

List<TicketRequest> ticketRequestsFromJson(String str) =>
    List<TicketRequest>.from(
        json.decode(str).map((x) => TicketRequest.fromJson(x)));

TicketRequest ticketRequestFromJson(String str) =>
    TicketRequest.fromJson(json.decode(str));

String ticketRequestToJson(TicketRequest data) => json.encode(data.toJson());

class TicketRequest {
  TicketEvent event;
  TicketOwner owner;
  Decision status;
  int id;

  TicketRequest({
    required this.event,
    required this.owner,
    required this.status,
    required this.id,
  });

  factory TicketRequest.fromJson(Map<String, dynamic> json) => TicketRequest(
        event: TicketEvent.fromJson(json["event"]),
        owner: TicketOwner.fromJson(json["owner"]),
        status: Decision.fromValue(json["status"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "event": event.toJson(),
        "owner": owner.toJson(),
        "status": status.value,
        "id": id,
      };
}
