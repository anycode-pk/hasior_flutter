import 'dart:convert';

import 'package:hasior_flutter/models/ticketEvent.dart';
import 'package:hasior_flutter/models/ticketOwner.dart';

List<Ticket> ticketsFromJson(String str) =>
    List<Ticket>.from(json.decode(str).map((x) => Ticket.fromJson(x)));

Ticket ticketFromJson(String str) => Ticket.fromJson(json.decode(str));

String ticketToJson(List<Ticket> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ticket {
  int id;
  String uniqeId;
  TicketEvent event;
  TicketOwner owner;
  TicketOwner singedBy;
  String createdAt;
  String description;
  bool isCanceled;

  Ticket({
    required this.id,
    required this.uniqeId,
    required this.event,
    required this.owner,
    required this.singedBy,
    required this.createdAt,
    required this.description,
    required this.isCanceled,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json["id"],
        uniqeId: json["uniqeId"],
        event: TicketEvent.fromJson(json["event"]),
        owner: TicketOwner.fromJson(json["owner"]),
        singedBy: TicketOwner.fromJson(json["singedBy"]),
        createdAt: json["createdAt"],
        description: json["description"],
        isCanceled: json["isCanceled"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uniqeId": uniqeId,
        "event": event.toJson(),
        "owner": owner.toJson(),
        "singedBy": singedBy.toJson(),
        "createdAt": createdAt,
        "description": description,
        "isCanceled": isCanceled,
      };
}
