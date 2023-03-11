import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasior_flutter/models/events.dart';
import 'package:hasior_flutter/models/calendar.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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
  }

  Future<List<Calendar>?> getCalendarEvents() async {
    var uri = Uri.parse("${url}Event/GetAllUpcomingEvents");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return calendarFromJson(json);
    }
  }

  Future<Image?> getFileByEventId(int id) async {
    var uri = Uri.parse("${url}HasiorFile/GetFileByEventId?eventId=$id");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes);
    }
  }
}
