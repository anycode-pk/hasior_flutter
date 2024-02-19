import 'dart:convert';

List<EventRequest> eventsFromJson(String str) => List<EventRequest>.from(
    json.decode(str).map((x) => EventRequest.fromJson(x)));

EventRequest eventFromJson(String str) =>
    EventRequest.fromJson(json.decode(str));

String eventsToJson(List<EventRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventRequest {
  EventRequest(
      {required this.id,
      required this.name,
      this.localization,
      required this.eventTime,
      required this.isCanceled,
      required this.categories});

  int id;
  String name;
  String? localization;
  String eventTime;
  bool isCanceled;
  List<int> categories;

  factory EventRequest.fromJson(Map<String, dynamic> json) => EventRequest(
        id: json["id"],
        name: json["name"],
        localization: json["localization"],
        eventTime: json["eventTime"],
        isCanceled: json["isCanceled"],
        categories: List<int>.from(json["categories"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "localization": localization,
        "eventTime": eventTime,
        "isCanceled": isCanceled,
        "categories": List<dynamic>.from(categories.map((x) => x)),
      };
}
