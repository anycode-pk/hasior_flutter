import 'package:hasior_flutter/models/calendar.dart';
import 'package:hasior_flutter/models/events.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<Calendar>?> getCalendar() async {
    var client = http.Client();
    var uri = Uri.parse("https://localhost:7226/api/Event/GetAllEvents");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return calendarFromJson(json);
    }
  }

  Future<List<Events>?> getCalendarEvents() async {
    var client = http.Client();
    var uri =
        Uri.parse("https://localhost:7226/api/Event/GetAllUpcomingEvents");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return eventsFromJson(json);
    }
  }
}
