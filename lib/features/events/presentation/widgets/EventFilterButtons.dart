import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class EventFilterButtons extends StatelessWidget {
  final String selectedType;
  final Function(String) onFilterChanged;

  const EventFilterButtons({
    super.key,
    required this.selectedType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => onFilterChanged('Todos'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectedType == 'Todos' ? AppColors.yellow : AppColors.black,
              foregroundColor:
                  selectedType == 'Todos' ? Colors.black : Colors.white,
            ),
            child: const Text('Todos'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onFilterChanged('Fiesta'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectedType == 'Fiesta' ? AppColors.yellow : AppColors.black,
              foregroundColor:
                  selectedType == 'Fiesta' ? Colors.black : Colors.white,
            ),
            child: const Text('Fiesta'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onFilterChanged('Festival'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectedType == 'Festival' ? AppColors.yellow : AppColors.black,
              foregroundColor:
                  selectedType == 'Festival' ? Colors.black : Colors.white,
            ),
            child: const Text('Festival'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onFilterChanged('Plazas'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectedType == 'Plazas' ? AppColors.yellow : AppColors.black,
              foregroundColor:
                  selectedType == 'Plazas' ? Colors.black : Colors.white,
            ),
            child: const Text('Plazas'),
          ),
        ],
      ),
    );
  }
}
