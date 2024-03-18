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
      this.images,
      this.favorite = false,
      this.isCanceled = false,
      this.categories});

  int id;
  String name;
  double? price;
  String? description;
  String? localization;
  String? ticketsLink;
  String eventTime;
  List<Thumbnail>? images;
  bool favorite;
  bool isCanceled;
  List<int>? categories;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        images: json["images"] == null
        ? List.empty() : List<Thumbnail>.from(json["images"].map((x) => Thumbnail.fromJson(x))),
        id: json["id"],
        name: json["name"],
        price: json["price"] == null
            ? null
            : double.parse(json["price"].toString()),
        description: json["description"],
        localization: json["localization"],
        ticketsLink: json["ticketsLink"],
        eventTime: json["eventTime"],
        favorite: json["favorite"],
        isCanceled: json["isCanceled"],
        categories: json["categories"] == null
          ? null
          : List<int>.from(json["categories"].map((x) => x))
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price?.round(),
        "description": description,
        "localization": localization,
        "ticketsLink": ticketsLink,
        "eventTime": eventTime,
        "images": images != null ? List<dynamic>.from(images!.map((x) => x.toJson())) : List.empty(),
        "favorite": favorite,
        "isCanceled": isCanceled,
        "categories": categories == null
            ? null
            : List<dynamic>.from(categories!.map((x) => x))
      };
}
