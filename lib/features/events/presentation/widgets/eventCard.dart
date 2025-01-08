import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import 'package:juvuit_flutter/core/utils/colors.dart'; // Asegúrate de ajustar la ruta

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white, // Fondo claro del Card
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
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del evento
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black, // Texto principal
                  ),
                ),
                // Subtítulo del evento
                Text(
                  event.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray, // Texto secundario
                  ),
                ),
                const SizedBox(height: 4),
                // Fecha y asistentes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fecha: ${event.date.day}/${event.date.month}/${event.date.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGray, // Información secundaria
                      ),
                    ),
                    Text(
                      'Asistentes: ${event.attendeesCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Asistir al evento ${event.title}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow, // Botón amarillo
                        foregroundColor: AppColors.black, // Texto negro
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Asistir'),
                    ),
                    const SizedBox(width: 50),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Más información del evento ${event.title}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black, // Texto amarillo
                        side: const BorderSide(color: AppColors.darkYellow), // Borde amarillo oscuro
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('+ Info'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
