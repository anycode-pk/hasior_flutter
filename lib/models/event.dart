import 'dart:convert';

import 'package:hasior_flutter/models/thumbnail.dart';

List<Event> eventsFromJson(String str) =>
    List<Event>.from(json.decode(str).map((x) => Event.fromJson(x)));

Event eventFromJson(String str) => Event.fromJson(json.decode(str));

String eventsToJson(List<Event> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Event {
  Event(
      {required this.id,
      required this.name,
      this.price,
      this.description,
      this.localization,
      this.ticketsLink,
      required this.eventTime,
      this.thumbnail,
      this.favorite = false});

  int id;
  String name;
  double? price;
  String? description;
  String? localization;
  String? ticketsLink;
  String eventTime;
  Thumbnail? thumbnail;
  bool favorite;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json["id"],
        name: json["name"],
        price: json["price"] == null
            ? null
            : double.parse(json["price"].toString()),
        description: json["description"],
        localization: json["localization"],
        ticketsLink: json["ticketsLink"],
        eventTime: json["eventTime"],
        thumbnail: json["thumbnail"] == null
            ? null
            : Thumbnail.fromJson(json["thumbnail"]),
        favorite: json["favorite"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price?.round(),
        "description": description,
        "localization": localization,
        "ticketsLink": ticketsLink,
        "eventTime": eventTime,
        "thumbnail": thumbnail?.toJson(),
        "favorite": favorite,
      };
}
