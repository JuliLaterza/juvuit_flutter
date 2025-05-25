import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
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
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Agrupar por:"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Fecha'),
                selected: _orderBy == 'fecha',
                onSelected: (_) => setState(() => _orderBy = 'fecha'),
                selectedColor: AppColors.yellow,
                labelStyle: TextStyle(
                  color: _orderBy == 'fecha' ? Colors.black : Colors.black,
                ),
              ),
              ChoiceChip(
                label: const Text('Asistentes'),
                selected: _orderBy == 'asistentes',
                onSelected: (_) => setState(() => _orderBy = 'asistentes'),
                selectedColor: AppColors.yellow,
                labelStyle: TextStyle(
                  color: _orderBy == 'asistentes' ? Colors.black : Colors.black,
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
