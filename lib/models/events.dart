import 'dart:convert';

import 'package:hasior_flutter/models/calendar.dart';

List<Events> eventsFromJson(String str) =>
    List<Events>.from(json.decode(str).map((x) => Events.fromJson(x)));

String eventsToJson(List<Events> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Events {
  String time;
  List<Calendar> events;

  Events({
    required this.time,
    required this.events,
  });

  factory Events.fromJson(Map<String, dynamic> json) => Events(
        time: json["time"],
        events: List<Calendar>.from(
            json["events"].map((x) => Calendar.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
      };
}
