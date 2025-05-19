import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import '../../widgets/matching_loader.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  String _orderBy = 'fecha';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos anotados'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Fecha'),
                selected: _orderBy == 'fecha',
                onSelected: (_) => setState(() => _orderBy = 'fecha'),
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: _orderBy == 'fecha' ? Colors.white : Colors.black,
                ),
              ),
              ChoiceChip(
                label: const Text('Asistentes'),
                selected: _orderBy == 'asistentes',
                onSelected: (_) => setState(() => _orderBy = 'asistentes'),
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: _orderBy == 'asistentes' ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: MatchingLoader(orderBy: _orderBy)),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
