import 'dart:convert';

import 'package:hasior_flutter/models/thumbnail.dart';

List<Events> eventsFromJson(String str) =>
    List<Events>.from(json.decode(str).map((x) => Events.fromJson(x)));

Events eventFromJson(String str) => Events.fromJson(json.decode(str));

String eventsToJson(List<Events> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Events {
  Events(
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

  factory Events.fromJson(Map<String, dynamic> json) => Events(
        id: json["id"],
        name: json["name"],
        price: json["thumbnail"] == null
            ? null
            : double.parse(json["price"].toString()), //TODO: poprawić do double
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
        "price": price?.round(), //TODO: poprawić do double
        "description": description,
        "localization": localization,
        "ticketsLink": ticketsLink,
        "eventTime": eventTime,
        "thumbnail": thumbnail?.toJson(),
        "favorite": favorite,
      };
}
