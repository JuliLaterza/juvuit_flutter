import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

import '../screens/event_info.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onAttend;

  const EventCard({
    super.key,
    required this.event,
    required this.onAttend,
  });


  

  @override
  Widget build(BuildContext context) {

    // ignore: unused_element
    void _showModalInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Información'),
          content: const Text('¡Bienvenido a la sección de eventos! Aquí podrás encontrar los eventos más importantes de la comunidad. Puedes filtrarlos por tipo y agregarlos a tu lista de eventos a los que asistirás.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
      );
    }


    return Card(
      color: AppColors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del evento
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              event.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  event.subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Fecha: ${event.date.day}/${event.date.month}/${event.date.year}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Asistentes: ${event.attendeesCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botones dentro de la tarjeta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  //onPressed: _showModalInfo,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventInfoScreen(event: event),
                      ),
                    );
                    
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.darkYellow),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('+ Info'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAttend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Asistir'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Venta de entradas ${event.title}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.darkYellow),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Comprar entradas!'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
