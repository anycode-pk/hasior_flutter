import 'dart:convert';
import 'package:hasior_flutter/models/ticket.dart';

ValidateTicket validateTicketFromJson(String str) =>
    ValidateTicket.fromJson(json.decode(str));

String validateTicketToJson(ValidateTicket data) => json.encode(data.toJson());

class ValidateTicket {
  Ticket? ticket;
  bool isCorrect;

  ValidateTicket({
    required this.ticket,
    required this.isCorrect,
  });

  factory ValidateTicket.fromJson(Map<String, dynamic> json) => ValidateTicket(
        ticket: json["ticket"] == null ? null : Ticket.fromJson(json["ticket"]),
        isCorrect: json["isCorrect"],
      );

  Map<String, dynamic> toJson() => {
        "ticket": ticket?.toJson(),
        "isCorrect": isCorrect,
      };
}
