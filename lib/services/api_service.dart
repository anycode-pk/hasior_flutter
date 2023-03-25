import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasior_flutter/models/events.dart';
import 'package:hasior_flutter/models/calendar.dart';
import 'package:hasior_flutter/models/login.dart';
import 'package:hasior_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String url = "https://localhost:7226/api/";
  final Client client = http.Client();

  Future<List<Events>?> getCalendar() async {
    var uri = Uri.parse("${url}Event/GetAllEvents");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return eventsFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getCalendarEvents() async {
    var uri = Uri.parse("${url}Event/GetAllUpcomingEvents");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getFavouriteEvents() async {
    var uri = Uri.parse("${url}FavouriteEvent");
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
    var uri = Uri.parse("${url}HasiorFile/GetFileByEventId?eventId=$id");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes);
    }
    throw FormatException(response.body);
  }

  Future<User?> loginUser(String email, String password) async {
    var uri = Uri.parse("${url}User/Login");
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
  }

  Future<bool> registerUser(
      String userName, String email, String password) async {
    var uri = Uri.parse("${url}User/Create");
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
  }

  Future<User?> getUserData(String token) async {
    var uri = Uri.parse("${url}User/GetUserData");
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
      return User.fromJson(userMap as Map<String, dynamic>);
    }
    return null;
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
  }
}
