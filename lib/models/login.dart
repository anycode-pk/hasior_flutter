import 'dart:convert';

Login loginFromJson(String str) => Login.fromJson(json.decode(str));

String loginToJson(Login data) => json.encode(data.toJson());

class Login {
  Login({
    required this.token,
    required this.refreshToken,
    required this.refreshTokenExpiryTime,
  });

  String token;
  String refreshToken;
  DateTime refreshTokenExpiryTime;

  factory Login.fromJson(Map<String, dynamic> json) => Login(
        token: json["token"],
        refreshToken: json["refreshToken"],
        refreshTokenExpiryTime: DateTime.parse(json["refreshTokenExpiryTime"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "refreshToken": refreshToken,
        "refreshTokenExpiryTime": refreshTokenExpiryTime.toIso8601String(),
      };
}
