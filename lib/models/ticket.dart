import 'dart:convert';

List<Ticket> ticketFromJson(String str) =>
    List<Ticket>.from(json.decode(str).map((x) => Ticket.fromJson(x)));

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

class TicketEvent {
  int id;
  String name;
  String eventTime;

  TicketEvent({
    required this.id,
    required this.name,
    required this.eventTime,
  });

  factory TicketEvent.fromJson(Map<String, dynamic> json) => TicketEvent(
        id: json["id"],
        name: json["name"],
        eventTime: json["eventTime"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "eventTime": eventTime,
      };
}

class TicketOwner {
  String id;
  String email;

  TicketOwner({
    required this.id,
    required this.email,
  });

  factory TicketOwner.fromJson(Map<String, dynamic> json) => TicketOwner(
        id: json["id"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
      };
}
