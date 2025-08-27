import '../models/event.dart';

List<Event> filterEventsByType(List<Event> events, String type) {
  if (type == 'Todos') {
    return events;
  } else {
    return events.where((event) => event.type == type).toList();
  }
}

// Nueva función para filtrar por ubicación (por ahora no afecta los datos reales)
List<Event> filterEventsByLocation(List<Event> events, String? province, String? zone) {
  // Por ahora, como los eventos no tienen datos de ubicación, retornamos todos
  // Cuando se agreguen los campos province y zone al modelo Event, aquí se implementará la lógica real
  return events;
}

// Función combinada para filtrar por tipo y ubicación
List<Event> filterEvents(List<Event> events, {
  required String type,
  String? province,
  String? zone,
}) {
  List<Event> filteredEvents = events;
  
  // Aplicar filtro por tipo
  filteredEvents = filterEventsByType(filteredEvents, type);
  
  // Aplicar filtros de ubicación (cuando estén disponibles)
  filteredEvents = filterEventsByLocation(filteredEvents, province, zone);
  
  return filteredEvents;
}
