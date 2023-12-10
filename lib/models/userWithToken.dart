import 'dart:convert';

import 'package:hasior_flutter/enums/role.dart';

UserWithToken userWithTokenFromJson(String str) =>
    UserWithToken.fromJson(json.decode(str));

String userWithTokenToJson(UserWithToken data) => json.encode(data.toJson());

class UserWithToken {
  UserWithToken({
    required this.id,
    required this.roles,
    required this.email,
    required this.userName,
    this.points,
    required this.token,
    required this.refreshToken,
    required this.refreshTokenExpiryTime,
  });

  String id;
  List<Role> roles;
  String email;
  String userName;
  int? points;
  String token;
  String refreshToken;
  DateTime refreshTokenExpiryTime;

  factory UserWithToken.fromJson(Map<String, dynamic> json) => UserWithToken(
        id: json["id"],
        roles: List<Role>.from(json["roles"].map((x) => roleValues.map[x]!)),
        email: json["email"],
        userName: json["userName"],
        points: json["points"],
        token: json["token"],
        refreshToken: json["refreshToken"],
        refreshTokenExpiryTime: DateTime.parse(json["refreshTokenExpiryTime"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "roles": List<dynamic>.from(roles.map((x) => roleValues.reverse[x])),
        "email": email,
        "userName": userName,
        "points": points,
        "token": token,
        "refreshToken": refreshToken,
        "refreshTokenExpiryTime": refreshTokenExpiryTime.toIso8601String(),
      };
}
