import 'package:juvuit_flutter/features/events/domain/models/event.dart';

final List<Event> events = [
  Event(
    id: '1',
    title: 'Fiesta en la Playa',
    subtitle: 'Música electrónica toda la noche',
    date: DateTime(2025, 1, 15),
    imageUrl: 'https://www.descuentoestudiante.com/uploads/wysiwyg/editor-20200415_105552rototom%20sun%20beach%20playas%20con%20fiesta.jpg',
    attendeesCount: 150,
    description: 'Loremp dmsaodas',
    type: 'Fiesta',
  ),
  Event(
    id: '2',
    title: 'LollaPalooza 2025',
    subtitle: 'Vivi la música como nunca',
    date: DateTime(2025, 3, 20),
    imageUrl: 'https://www.cronista.com/files/image/939/939237/66d70db5e6bdf.jpg',
    attendeesCount: 200,
    description: 'Loremp dmsaodas',
    type: 'Festival',
  ),
  Event(
    id: '3',
    title: 'Coachella',
    subtitle: 'Festival icónico de música, arte y moda en el desierto.',
    date: DateTime(2025, 3, 25),
    imageUrl: 'https://e00-mx-marca.uecdn.es/mx/assets/multimedia/imagenes/2024/11/21/17321530742235.jpg',
    attendeesCount: 100,
    description: 'Loremp dmsaodas',
    type: 'Festival',
  ),
];
