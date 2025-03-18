import 'package:flutter/material.dart';
import 'package:oservice/entities/collaborator.dart';

class CollaboratorDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<Collaborator> filteredCollaborators;
  final List<Collaborator> chosenCollaborators;
  final bool englishLesson;
  final Function(Collaborator?) onSelected;

  const CollaboratorDropdown({
    super.key,
    required this.controller,
    required this.filteredCollaborators,
    required this.chosenCollaborators,
    required this.englishLesson,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<Collaborator>(
              width: 400,
              inputDecorationTheme: InputDecorationTheme(
                border: UnderlineInputBorder(),
              ),
              hintText: 'Seleziona un collaboratore',
              controller: controller,
              enableFilter: true,
              dropdownMenuEntries: filteredCollaborators.map((collaborator) {
                return DropdownMenuEntry<Collaborator>(
                  value: collaborator,
                  labelWidget: chosenCollaborators.any(
                    (element) => element.name == collaborator.name,
                  )
                      ? Row(
                          children: [
                            Icon(
                              Icons.remove,
                              color: Colors.red.shade700,
                            ),
                            Text(collaborator.name),
                            englishLesson && collaborator.englishSpeaker
                                ? Icon(Icons.flag_rounded)
                                : SizedBox(),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.green.shade700,
                            ),
                            Text(collaborator.name),
                            englishLesson && collaborator.englishSpeaker
                                ? Icon(Icons.flag_rounded)
                                : SizedBox(),
                          ],
                        ),
                  label: collaborator.name,
                );
              }).toList(),
              searchCallback: (entries, query) {
                final String searchText = controller.value.text.toLowerCase();
                if (searchText.isEmpty) {
                  return null;
                }
                final int index = entries.indexWhere(
                    (DropdownMenuEntry<Collaborator> entry) =>
                        entry.label.toLowerCase().contains(searchText));
                return index != -1 ? index : null;
              },
              onSelected: (Collaborator? collaborator) {
                if (collaborator != null) {
                  onSelected(collaborator);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
