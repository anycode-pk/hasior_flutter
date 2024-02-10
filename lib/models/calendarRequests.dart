import 'dart:convert';

import 'package:hasior_flutter/models/eventRequest.dart';

List<CalendarRequests> calendarRequestFromJson(String str) =>
    List<CalendarRequests>.from(
        json.decode(str).map((x) => CalendarRequests.fromJson(x)));

String calendarRequestToJson(List<CalendarRequests> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CalendarRequests {
  CalendarRequests({
    required this.time,
    required this.events,
  });

  String time;
  List<EventRequest> events;

  factory CalendarRequests.fromJson(Map<String, dynamic> json) =>
      CalendarRequests(
        time: json["time"],
        events: List<EventRequest>.from(
            json["events"].map((x) => EventRequest.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
      };
}
