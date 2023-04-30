import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasior_flutter/models/events.dart';
import 'package:hasior_flutter/models/calendar.dart';
import 'package:hasior_flutter/models/login.dart';
import 'package:hasior_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String url = "https://localhost:7226/api/";
  final Client client = http.Client();

  Future<List<Events>?> getCalendar() async {
    var uri = Uri.parse("${await getApiAddress()}Event/GetAllEvents");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return eventsFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getAllUpcomingEvents([String? name]) async {
    var uri = Uri.parse(
        "${await getApiAddress()}Event/GetAllUpcomingEvents${name != null ? "?EventName=$name" : ""}");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getAllUpcomingEventsForUser([String? name]) async {
    var uri = Uri.parse(
        "${await getApiAddress()}Event/GetAllUpcomingEventsForUser${name != null ? "?EventName=$name" : ""}");
    User? user = await userFromSharedPreferences();
    var response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      var json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getFavouriteEvents([String? name]) async {
    var uri = Uri.parse(
        "${await getApiAddress()}FavouriteEvent${name != null ? "?EventName=$name" : ""}");
    User? user = await userFromSharedPreferences();
    var response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      var json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<Image?> getFileByEventId(int id) async {
    var uri = Uri.parse(
        "${await getApiAddress()}HasiorFile/GetFileByEventId?eventId=$id");
    var response = await client.get(uri);
    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return Image.memory(response.bodyBytes);
    }
    return null;
    //throw FormatException(response.body);
  }

  Future<bool> addFavouriteEvent(int id) async {
    var uri = Uri.parse("${await getApiAddress()}FavouriteEvent?eventId=$id");
    User? user = await userFromSharedPreferences();
    var response = await client.post(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      return true;
    }
    throw FormatException(response.body);
  }

  Future<bool> deleteFavouriteEvent(int id) async {
    var uri = Uri.parse("${await getApiAddress()}FavouriteEvent/$id");
    User? user = await userFromSharedPreferences();
    var response = await client.delete(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      return true;
    }
    throw FormatException(response.body);
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      var uri = Uri.parse("${await getApiAddress()}User/Login");
      var response = await client.post(uri,
          headers: {
            "content-type": "application/json",
            "accept": "text/plain",
          },
          body: jsonEncode({
            "email": email,
            "password": password,
          }));
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var loginArr = loginFromJson(response.body);
        var userData = await getUserData(loginArr.token);
        if (userData != null) {
          userData.token = loginArr.token;
          String user = jsonEncode(userData);
          prefs.setString("user", user);
          return userData;
        }
      }
      throw FormatException(response.body);
    } on SocketException catch (e) {
      throw FormatException(e.message);
    }
  }

  Future<bool> registerUser(
      String userName, String email, String password) async {
    try {
      var uri = Uri.parse("${await getApiAddress()}User/Create");
      var response = await client.post(uri,
          headers: {
            "content-type": "application/json",
          },
          body: jsonEncode({
            "userName": userName,
            "email": email,
            "password": password,
          }));
      if (response.statusCode == 200) {
        return true;
      }
      throw FormatException(response.body);
    } on SocketException catch (e) {
      throw FormatException(e.message);
    }
  }

  Future<User?> getUserData(String token) async {
    var uri = Uri.parse("${await getApiAddress()}User/GetUserData");
    var response = await client.get(uri,
        headers: {"accept": "text/plain", "Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      return userFromJson(response.body);
    }
    throw FormatException(response.body);
  }

  Future<User?> userFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString("user");
    if (userString != null) {
      Map userMap = jsonDecode(userString);
      User user = User.fromJson(userMap as Map<String, dynamic>);
      bool hasExpired = JwtDecoder.isExpired(user.token ?? "");
      if (hasExpired) {
        await prefs.remove("user");
        return null;
      }
      return user;
    }
    return null;
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
  }

  Future<String> getApiAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("apiAddress") ?? "https://localhost:7226/api/";
  }
}
