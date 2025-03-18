import 'package:flutter/material.dart';
import 'package:oservice/entities/entity.dart';

class EntityDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<Entity> filteredEntities;
  final Function(Entity?) onSelected;

  const EntityDropdown({
    super.key,
    required this.controller,
    required this.filteredEntities,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<Entity>(
              width: 400,
              inputDecorationTheme: InputDecorationTheme(
                border: UnderlineInputBorder(),
              ),
              hintText: 'Seleziona un ente',
              controller: controller,
              enableFilter: true,
              dropdownMenuEntries: filteredEntities.map((entity) {
                return DropdownMenuEntry<Entity>(
                  value: entity,
                  label: entity.name,
                );
              }).toList(),
              searchCallback: (entries, query) {
                final String searchText = controller.value.text.toLowerCase();
                if (searchText.isEmpty) {
                  return null;
                }
                final int index = entries.indexWhere(
                        (DropdownMenuEntry<Entity> entry) =>
                        entry.label.toLowerCase().contains(searchText));
                return index != -1 ? index : null;
              },
              onSelected: (Entity? Entity) {
                if (Entity != null) {
                  onSelected(Entity);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
