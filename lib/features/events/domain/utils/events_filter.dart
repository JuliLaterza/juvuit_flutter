import '../models/event.dart';

List<Event> filterEventsByType(List<Event> events, String type) {
  if (type == 'Todos') {
    return events;
  } else {
    return events.where((event) => event.type == type).toList();
  }
}
