import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/event.dart';

class EventInfoScreen extends StatelessWidget {
  const EventInfoScreen({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity, // Asegura que el contenido ocupa el ancho disponible
            padding: const EdgeInsets.all(8.0), // Agrega padding al contenido
            child: Column(
              mainAxisSize: MainAxisSize.min, // Permite que el contenido se adapte
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
              children: [
                Image.network(
                  event.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(event.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(event.date)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('Costo: 170000 - 250000', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Ubicación: Costanera Norte", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                
                const Placeholder(fallbackHeight: 180),
                const Text("Agregar API de Google Maps"),
                const SizedBox(height: 10),
                // Envolver los botones en un Row y asegurarse que no se desborden
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Unirse al evento'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Compartir evento'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Comprar Entradas'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
