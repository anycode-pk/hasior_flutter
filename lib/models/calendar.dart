// To parse this JSON data, do
//
//     final calendar = calendarFromJson(jsonString);

import 'dart:convert';

List<Calendar> calendarFromJson(String str) =>
    List<Calendar>.from(json.decode(str).map((x) => Calendar.fromJson(x)));

String calendarToJson(List<Calendar> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Calendar {
  Calendar({
    required this.name,
    required this.price,
    required this.description,
    required this.localization,
    required this.ticketsLink,
    required this.eventTime,
    required this.thumbnailId,
  });

  String name;
  double price;
  String description;
  String localization;
  String ticketsLink;
  String eventTime;
  int thumbnailId;

  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
        name: json["name"],
        price: json["price"],
        description: json["description"],
        localization: json["localization"],
        ticketsLink: json["ticketsLink"],
        eventTime: json["eventTime"],
        thumbnailId: json["thumbnailId"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "description": description,
        "localization": localization,
        "ticketsLink": ticketsLink,
        "eventTime": eventTime,
        "thumbnailId": thumbnailId,
      };
}
