import 'dart:convert';
import 'dart:io';
import 'package:hasior_flutter/enums/decision.dart';
import 'package:hasior_flutter/models/calendarRequests.dart';
import 'package:hasior_flutter/models/ticket.dart';
import 'package:hasior_flutter/models/ticketRequest.dart';
import 'package:hasior_flutter/models/ticketRequestDecision.dart';
import 'package:hasior_flutter/models/validateTicket.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hasior_flutter/models/event.dart';
import 'package:hasior_flutter/models/calendar.dart';
import 'package:hasior_flutter/models/login.dart';
import 'package:hasior_flutter/models/user.dart';
import 'package:hasior_flutter/models/userWithToken.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

import '../models/token.dart';

class ApiService {
  final String url = "https://dev.bytebunka.net/api/";
  final Client client = http.Client();

  Future<List<Event>?> getCalendar() async {
    Uri uri = Uri.parse("${await getApiAddress()}event/all-events");
    Response response = await client.get(uri);
    if (response.statusCode == 200) {
      String json = response.body;
      return eventsFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getAllUpcomingEvents([String? name]) async {
    Uri uri = Uri.parse(
        "${await getApiAddress()}event/all-upcoming-events${name != null ? "?EventName=$name" : ""}");
    Response response = await client.get(uri);
    if (response.statusCode == 200) {
      String json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getAllUpcomingEventsForUser([String? name]) async {
    Uri uri = Uri.parse(
        "${await getApiAddress()}event/all-upcoming-events/user${name != null ? "?EventName=$name" : ""}");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      String json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<CalendarRequests>?> getAllUpcomingEventsForTicketRequest(
      [String? name, Decision? status]) async {
    Uri uri = Uri.parse(
        "${await getApiAddress()}event/all-upcoming-events/ticket-request${name != null ? "?EventName=$name" : ""}${status != null ? "?TicketStatuses=${status.index}" : ""}");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      String json = response.body;
      return calendarRequestFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<TicketRequest>?> getAllEventTicketRequests(int id) async {
    Uri uri = Uri.parse("${await getApiAddress()}ticket/requests/event/$id");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      String json = response.body;
      return ticketRequestsFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<List<Calendar>?> getFavouriteEvents([String? name]) async {
    Uri uri = Uri.parse(
        "${await getApiAddress()}favourite-event${name != null ? "?EventName=$name" : ""}");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      String json = response.body;
      return calendarFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<bool> addFavouriteEvent(int id) async {
    Uri uri = Uri.parse("${await getApiAddress()}favourite-event/$id");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.post(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      return true;
    }
    throw FormatException(response.body);
  }

  Future<bool> deleteFavouriteEvent(int id) async {
    Uri uri = Uri.parse("${await getApiAddress()}favourite-event/$id");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.delete(uri, headers: {
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
      Uri uri = Uri.parse("${await getApiAddress()}user/login");
      Response response = await client.post(uri,
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
        Login loginArr = loginFromJson(response.body);
        User? userData = await getUserData(loginArr.token);
        if (userData != null) {
          UserWithToken user = UserWithToken(
              id: userData.id,
              roles: userData.roles,
              email: userData.email,
              userName: userData.userName,
              points: userData.points,
              token: loginArr.token,
              refreshToken: loginArr.refreshToken,
              refreshTokenExpiryTime: loginArr.refreshTokenExpiryTime);
          String userJson = jsonEncode(user);
          prefs.setString("user", userJson);
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
      Uri uri = Uri.parse("${await getApiAddress()}user/register");
      Response response = await client.post(uri,
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

  Future<Event?> createEvent(String name, double? price, String? description,
      String? localization, String? ticketsLink, DateTime eventTime) async {
    try {
      Uri uri = Uri.parse("${await getApiAddress()}event/simple-event");
      UserWithToken? user = await userFromSharedPreferences();
      Response response = await client.post(uri,
          headers: {
            "content-type": "application/json",
            "Authorization": "Bearer ${user?.token}"
          },
          body: jsonEncode({
            "name": name,
            "price": price,
            "description": description,
            "localization": localization,
            "ticketsLink": ticketsLink,
            "eventTime": eventTime.toIso8601String(),
          }));
      if (response.statusCode == 200) {
        String json = response.body;
        return eventFromJson(json);
      }
      throw FormatException(response.body);
    } on SocketException catch (e) {
      throw FormatException(e.message);
    }
  }

  Future<bool> putImageToEvent(int id, File image) async {
    try {
      Uri uri = Uri.parse("${await getApiAddress()}file/event/$id");
      MultipartRequest request = http.MultipartRequest("PUT", uri);
      UserWithToken? user = await userFromSharedPreferences();
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
        "Authorization": "Bearer ${user?.token}"
      });
      request.files.add(http.MultipartFile.fromBytes(
          'file', image.readAsBytesSync(),
          filename: basename(image.path),
          contentType: MediaType('image', 'jpg')));
      StreamedResponse response = await request.send();
      if (response.statusCode == 200) return true;
      return false;
    } on SocketException catch (e) {
      throw FormatException(e.message);
    }
  }

  Future<bool> putNullImageToEvent(int id) async {
    Uri uri = Uri.parse("${await getApiAddress()}file/event/$id");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.delete(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      return true;
    }
    throw FormatException(response.body);
  }

  Future<List<TicketRequest>?> getTicketRequests() async {
    Uri uri = Uri.parse("${await getApiAddress()}ticket/requests/user");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      String json = response.body;
      return ticketRequestsFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<bool> editEvent(
      int id,
      String name,
      double? price,
      String? description,
      String? localization,
      String? ticketsLink,
      DateTime eventTime) async {
    try {
      Uri uri = Uri.parse("${await getApiAddress()}event");
      UserWithToken? user = await userFromSharedPreferences();
      Response response = await client.put(uri,
          headers: {
            "content-type": "application/json",
            "Authorization": "Bearer ${user?.token}"
          },
          body: jsonEncode({
            "id": id,
            "name": name,
            "price": price,
            "description": description,
            "localization": localization,
            "ticketsLink": ticketsLink,
            "eventTime": eventTime.toIso8601String(),
          }));
      if (response.statusCode == 200) {
        return true;
      }
      throw FormatException(response.body);
    } on SocketException catch (e) {
      throw FormatException(e.message);
    }
  }

  Future<bool> cancelEvent(int id) async {
    Uri uri = Uri.parse("${await getApiAddress()}event/$id/cancel");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.put(uri, headers: {
      "content-type": "application/json",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      return true;
    }
    throw FormatException(response.body);
  }

  Future<ValidateTicket?> validateTicket(String token) async {
    try {
      Uri uri = Uri.parse("${await getApiAddress()}ticket/validate-token");
      UserWithToken? user = await userFromSharedPreferences();
      Response response = await client.put(uri,
          headers: {
            "content-type": "application/json",
            "Authorization": "Bearer ${user?.token}"
          },
          body: jsonEncode({
            "token": token,
          }));
      if (response.statusCode == 200) {
        String json = response.body;
        return validateTicketFromJson(json);
      }
      throw FormatException(response.body);
    } on SocketException catch (e) {
      throw FormatException(e.message);
    }
  }

  Future<User?> getUserData(String token) async {
    Uri uri = Uri.parse("${await getApiAddress()}user/user-data");
    Response response = await client.get(uri,
        headers: {"accept": "text/plain", "Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      return userFromJson(response.body);
    }
    throw FormatException(response.body);
  }

  Future<UserWithToken?> userFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString("user");
    if (userString != null) {
      Map userMap = jsonDecode(userString);
      UserWithToken user =
          UserWithToken.fromJson(userMap as Map<String, dynamic>);
      bool hasExpired = JwtDecoder.isExpired(user.token);
      if (hasExpired) {
        bool isExpired = user.refreshTokenExpiryTime.isBefore(DateTime.now());
        if (!isExpired) {
          Token token = await refreshToken(user.refreshToken, user.token);
          user.token = token.token;
        } else {
          await prefs.remove("user");
          return null;
        }
      }
      return user;
    }
    return null;
  }

  Future<List<Ticket>?> getTickets() async {
    Uri uri = Uri.parse("${await getApiAddress()}ticket/user");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.get(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      String json = response.body;
      List<Ticket> result = ticketsFromJson(json);
      await saveTicketsToSharedPreferences(result);
      return result;
    }
    throw FormatException(response.body);
  }

  Future<void> saveTicketsToSharedPreferences(List<Ticket> tickets) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ticketsJson = jsonEncode(tickets);
    prefs.setString("tickets", ticketsJson);
  }

  Future<List<Ticket>?> getTicketsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ticketsString = prefs.getString("tickets");
    if (ticketsString != null) {
      List<Ticket> tickets = ticketsFromJson(ticketsString);
      return tickets;
    }
    return null;
  }

  Future<bool> sendRequestForTicket(int id) async {
    Uri uri = Uri.parse("${await getApiAddress()}ticket/event/$id/requests");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.post(uri, headers: {
      "accept": "text/plain",
      "Authorization": "Bearer ${user?.token}"
    });
    if (response.statusCode == 200) {
      return true;
    }
    throw FormatException(response.body);
  }

  Future<List<TicketRequest>?> ticketRequestDecision(
      List<TicketRequestDecision> ticketRequestDecision) async {
    Uri uri = Uri.parse("${await getApiAddress()}ticket/requests");
    UserWithToken? user = await userFromSharedPreferences();
    Response response = await client.put(uri,
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${user?.token}"
        },
        body: jsonEncode({
          "ticketRequests":
              List<dynamic>.from(ticketRequestDecision.map((x) => x.toJson()))
        }));
    if (response.statusCode == 200) {
      String json = response.body;
      return ticketRequestsFromJson(json);
    }
    throw FormatException(response.body);
  }

  Future<Token> refreshToken(String refreshToken, String accesToken) async {
    Uri uri = Uri.parse("${await getApiAddress()}user/refresh-token");
    Response response = await client.post(uri,
        headers: {
          "accept": "text/plain",
          "content-type": "application/json",
        },
        body: jsonEncode({
          "refreshToken": refreshToken,
          "accesToken": accesToken,
        }));
    if (response.statusCode == 200) {
      return tokenFromJson(response.body);
    }
    if (response.statusCode == 400) {
      await logout();
      await userFromSharedPreferences();
    }
    throw FormatException(response.body);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
  }

  Future<String> getApiAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("apiAddress") ?? url;
  }
}
