import 'package:flutter/material.dart';
import 'package:oservice/entities/exercise.dart';

class ExerciseDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<Exercise> filteredExercises;
  final List<Exercise> chosenExercises;
  final Function(Exercise?) onSelected;

  const ExerciseDropdown({
    super.key,
    required this.controller,
    required this.filteredExercises,
    required this.chosenExercises,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<Exercise>(
              width: 400,
              inputDecorationTheme: InputDecorationTheme(
                border: UnderlineInputBorder(),
              ),
              hintText: 'Seleziona un esercizio',
              controller: controller,
              enableFilter: true,
              dropdownMenuEntries: filteredExercises.map((exercise) {
                return DropdownMenuEntry<Exercise>(
                  value: exercise,
                  labelWidget: chosenExercises.any(
                    (element) => element.title == exercise.title,
                  )
                      ? Row(
                          children: [
                            Icon(
                              Icons.remove,
                              color: Colors.red.shade700,
                            ),
                            Text(exercise.title),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.green.shade700,
                            ),
                            Text(exercise.title),
                          ],
                        ),
                  label: exercise.title,
                );
              }).toList(),
              searchCallback: (entries, query) {
                final String searchText = controller.value.text.toLowerCase();
                if (searchText.isEmpty) {
                  return null;
                }
                final int index = entries.indexWhere(
                    (DropdownMenuEntry<Exercise> entry) =>
                        entry.label.toLowerCase().contains(searchText));
                return index != -1 ? index : null;
              },
              onSelected: (Exercise? Exercise) {
                if (Exercise != null) {
                  onSelected(Exercise);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
