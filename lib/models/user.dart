import 'dart:convert';

import 'package:hasior_flutter/enums/role.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    required this.id,
    required this.roles,
    required this.email,
    required this.userName,
    this.points,
  });

  String id;
  List<Role> roles;
  String email;
  String userName;
  int? points;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        roles: List<Role>.from(json["roles"].map((x) => roleValues.map[x]!)),
        email: json["email"],
        userName: json["userName"],
        points: json["points"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "roles": List<dynamic>.from(roles.map((x) => roleValues.reverse[x])),
        "email": email,
        "userName": userName,
        "points": points,
      };
}
