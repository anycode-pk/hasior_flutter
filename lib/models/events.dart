import 'dart:convert';

List<Events> eventsFromJson(String str) =>
    List<Events>.from(json.decode(str).map((x) => Events.fromJson(x)));

String eventsToJson(List<Events> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Events {
  Events({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.localization,
    required this.ticketsLink,
    required this.eventTime,
    required this.thumbnailId,
  });

  int id;
  String name;
  double price;
  String description;
  String localization;
  String ticketsLink;
  String eventTime;
  int thumbnailId;

  factory Events.fromJson(Map<String, dynamic> json) => Events(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        description: json["description"],
        localization: json["localization"],
        ticketsLink: json["ticketsLink"],
        eventTime: json["eventTime"],
        thumbnailId: json["thumbnailId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "description": description,
        "localization": localization,
        "ticketsLink": ticketsLink,
        "eventTime": eventTime,
        "thumbnailId": thumbnailId,
      };
}
