// location_dropdown.dart
import 'package:flutter/material.dart';
import 'package:oservice/entities/location.dart';

class LocationDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<Location> filteredLocations;
  final Function(Location?) onSelected;

  const LocationDropdown({
    super.key,
    required this.controller,
    required this.filteredLocations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<Location>(
              width: 400,
              inputDecorationTheme: InputDecorationTheme(
                border: UnderlineInputBorder(),
              ),
              hintText: 'Seleziona una posizione',
              controller: controller,
              enableFilter: true,
              dropdownMenuEntries: filteredLocations.map((location) {
                return DropdownMenuEntry<Location>(
                  value: location,
                  label: location.title,
                );
              }).toList(),
              searchCallback: (entries, query) {
                final String searchText = controller.value.text.toLowerCase();
                if (searchText.isEmpty) {
                  return null;
                }
                final int index = entries.indexWhere(
                        (DropdownMenuEntry<Location> entry) =>
                        entry.label.toLowerCase().contains(searchText));
                return index != -1 ? index : null;
              },
              onSelected: (Location? location) {
                if (location != null) {
                  onSelected(location);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
