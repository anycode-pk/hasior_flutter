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
