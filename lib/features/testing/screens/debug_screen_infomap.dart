import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugScreenApiMap extends StatelessWidget {
  const DebugScreenApiMap({super.key});

  Future<void> _openMap() async {
    const double lat = -34.48031994132784; //-34.48031994132784, -58.520784489340734
    const double lng = -58.520784489340734;
    final Uri googleMapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el mapa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Api de GoogleMap'),
      ),
      body: SafeArea(
        child: Center(
          child: ListTile(
            leading: const Icon(Icons.map, color: Colors.blue),
            title: const Text("Ubicación del Evento"),
            subtitle: const Text("Tocá para abrir en Google Maps"),
            onTap: _openMap,
          ),
        ),
      ),
    );
  }
}
