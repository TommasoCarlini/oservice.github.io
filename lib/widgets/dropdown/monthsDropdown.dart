import 'package:flutter/material.dart';
import 'package:oservice/enums/months.dart';

class MonthsDropdown extends StatefulWidget {
  final Month? initialMonth;
  final ValueChanged<Month>? onChanged;

  const MonthsDropdown({
    super.key,
    this.initialMonth,
    this.onChanged,
  });

  @override
  _MonthsDropdownState createState() => _MonthsDropdownState();
}

class _MonthsDropdownState extends State<MonthsDropdown> {
  late Month selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth =
        widget.initialMonth ?? Month.fromNumber(DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Month>(
      value: selectedMonth,
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (Month? newValue) {
        if (newValue != null) {
          setState(() {
            selectedMonth = newValue;
          });
          widget.onChanged?.call(newValue);
        }
      },
      items: Month.values.map((Month month) {
        return DropdownMenuItem<Month>(
          value: month,
          child: Text(
            month.name,
            style: Theme.of(context).primaryTextTheme.titleMedium,
          ),
        );
      }).toList(),
    );
  }
}
