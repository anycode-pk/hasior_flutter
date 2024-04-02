import 'dart:convert';

HasiorThredReactions thumbnailFromJson(String str) => HasiorThredReactions.fromJson(json.decode(str));

List<HasiorThredReactions> ticketRequestsFromJson(String str) =>
    List<HasiorThredReactions>.from(
        json.decode(str).map((x) => HasiorThredReactions.fromJson(x)));

String thumbnailToJson(HasiorThredReactions data) => json.encode(data.toJson());

class HasiorThredReactions {
  HasiorThredReactions(
      {
      required this.type,
      required this.amount});

  int type;
  int amount;

  factory HasiorThredReactions.fromJson(Map<String, dynamic> json) => HasiorThredReactions(
        type: json["type"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "amount": amount,
      };
}