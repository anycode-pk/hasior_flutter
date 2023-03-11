import 'dart:convert';

import 'package:hasior_flutter/models/events.dart';

List<Calendar> calendarFromJson(String str) =>
    List<Calendar>.from(json.decode(str).map((x) => Calendar.fromJson(x)));

String calendarToJson(List<Calendar> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Calendar {
  String time;
  List<Events> events;

  Calendar({
    required this.time,
    required this.events,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
        time: json["time"],
        events:
            List<Events>.from(json["events"].map((x) => Events.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
      };
}
