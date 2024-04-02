import 'package:hasior_flutter/models/HasiorThredReactions.dart';
import 'package:hasior_flutter/models/thumbnail.dart';

class HasiorThred {
  HasiorThred(
      {required this.id,
      required this.text,
      required this.isPrivate,
      required this.amountOfComments,
      required this.reactions});

  int id;
  String text;
  bool isPrivate;
  int amountOfComments;
  List<HasiorThredReactions> reactions;

    factory HasiorThred.fromJson(Map<String, dynamic> json) => HasiorThred(
        id: json["id"],
        text: json["text"],
        isPrivate: json["isPrivate"],
        amountOfComments: json["amountOfComments"],
        reactions: json["amountOfComments"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "isPrivate": isPrivate,
        "amountOfComments": amountOfComments,
      };
}