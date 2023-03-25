import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    required this.id,
    required this.roles,
    required this.email,
    required this.userName,
    this.points,
    this.token,
  });

  String id;
  List<String> roles;
  String email;
  String userName;
  int? points;
  String? token;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        roles: List<String>.from(json["roles"].map((x) => x)),
        email: json["email"],
        userName: json["userName"],
        points: json["points"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "roles": List<dynamic>.from(roles.map((x) => x)),
        "email": email,
        "userName": userName,
        "points": points,
        "token": token,
      };
}
