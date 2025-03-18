import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

class DateRowWidget extends StatelessWidget {
  final bool isSchoolCamp;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<TimeRange> onTimeChanged;

  const DateRowWidget({
    super.key,
    required this.isSchoolCamp,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {

    void dateTimePicker() async {
      DateTime? pickedStartDate = await showDatePicker(
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.deepOrangeAccent,
                  onSurface: Colors.black87,
                  onPrimary: Colors.black87,
                ),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.deepOrangeAccent,
                  selectionColor: Colors.deepOrangeAccent,
                  selectionHandleColor: Colors.deepOrangeAccent,
                ),
              ),
              child: child!);
        },
        locale: Locale('it'),
        context: context,
        initialDate: startDate,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 2),
      );
      if (pickedStartDate != null) {
        onStartDateChanged(pickedStartDate);
      }
      return;
    }

    void dateRangePicker() async {
      DateTimeRange? pickedDateRange = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.deepOrangeAccent,
                onSurface: Colors.black87,
                onPrimary: Colors.black87,
              ),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.deepOrangeAccent,
                selectionColor: Colors.deepOrangeAccent,
                selectionHandleColor: Colors.deepOrangeAccent,
              ),
            ),
            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 600.0,
                  width: 400.0,
                  child: DateRangePickerDialog(
                      firstDate: DateTime(DateTime.now().year),
                      lastDate: DateTime(DateTime.now().year + 2)),
                )),
          );
        },
      );
      if (pickedDateRange != null) {
        onStartDateChanged(pickedDateRange.start);
        onEndDateChanged(pickedDateRange.end);
      }
      return;
    }

    void timeRangePicker() async {
      TimeRange? pickedTime = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 400,
              height: 600,
              child: TimeRangePicker(
                use24HourFormat: true,
                fromText: 'Dalle',
                toText: 'Alle',
                strokeColor: Colors.deepOrangeAccent,
                handlerColor: Colors.deepOrangeAccent,
                clockRotation: 180,
                interval: Duration(minutes: 15),
                ticks: 24,
                ticksColor: Colors.deepOrangeAccent,
                labels: [
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 00, minute: 00), text: '00'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 01, minute: 00), text: '01'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 02, minute: 00), text: '02'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 03, minute: 00), text: '03'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 04, minute: 00), text: '04'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 05, minute: 00), text: '05'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 06, minute: 00), text: '06'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 07, minute: 00), text: '07'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 08, minute: 00), text: '08'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 09, minute: 00), text: '09'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 10, minute: 00), text: '10'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 11, minute: 00), text: '11'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 12, minute: 00), text: '12'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 13, minute: 00), text: '13'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 14, minute: 00), text: '14'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 15, minute: 00), text: '15'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 16, minute: 00), text: '16'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 17, minute: 00), text: '17'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 18, minute: 00), text: '18'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 19, minute: 00), text: '19'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 20, minute: 00), text: '20'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 21, minute: 00), text: '21'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 22, minute: 00), text: '22'),
                  ClockLabel.fromTime(
                      time: TimeOfDay(hour: 23, minute: 00), text: '23'),
                  // ClockLabel.fromTime(time: TimeOfDay(hour: 24, minute: 00), text: '24'),
                ],
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                labelOffset: -32,
                rotateLabels: false,
                selectedColor: Colors.deepOrangeAccent,
              ),
            ),
          );
        },
      );
      if (pickedTime != null) {
        onTimeChanged(pickedTime);
        onEndDateChanged(DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          pickedTime.endTime.hour,
          pickedTime.endTime.minute,
        ));
      }
    }

    // showTimeRangePicker(
    //   builder: (BuildContext context, Widget? child) {
    //     return Theme(
    //       data: ThemeData.light().copyWith(
    //         colorScheme: ColorScheme.light(
    //           primary: Colors.deepOrangeAccent,
    //           onSurface: Colors.black87,
    //           onPrimary: Colors.black87,
    //         ),
    //         textSelectionTheme: TextSelectionThemeData(
    //           cursorColor: Colors.deepOrangeAccent,
    //           selectionColor: Colors.deepOrangeAccent,
    //           selectionHandleColor: Colors.deepOrangeAccent,
    //         ),
    //       ),
    //       child: MediaQuery(
    //         data:
    //         MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
    //         child: child!,
    //       ),
    //     );
    //   },
    //   fromText: 'Dalle',
    //   toText: 'Alle',
    //   strokeColor: Colors.deepOrangeAccent,
    //   handlerColor: Colors.deepOrangeAccent,
    //   clockRotation: 180,
    //   interval: Duration(minutes: 15),
    //   ticks: 24,
    //   ticksColor: Colors.deepOrangeAccent,
    //   labels: [
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 00, minute: 00), text: '00'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 01, minute: 00), text: '01'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 02, minute: 00), text: '02'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 03, minute: 00), text: '03'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 04, minute: 00), text: '04'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 05, minute: 00), text: '05'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 06, minute: 00), text: '06'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 07, minute: 00), text: '07'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 08, minute: 00), text: '08'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 09, minute: 00), text: '09'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 10, minute: 00), text: '10'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 11, minute: 00), text: '11'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 12, minute: 00), text: '12'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 13, minute: 00), text: '13'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 14, minute: 00), text: '14'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 15, minute: 00), text: '15'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 16, minute: 00), text: '16'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 17, minute: 00), text: '17'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 18, minute: 00), text: '18'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 19, minute: 00), text: '19'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 20, minute: 00), text: '20'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 21, minute: 00), text: '21'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 22, minute: 00), text: '22'),
    //     ClockLabel.fromTime(
    //         time: TimeOfDay(hour: 23, minute: 00), text: '23'),
    //     // ClockLabel.fromTime(time: TimeOfDay(hour: 24, minute: 00), text: '24'),
    //   ],
    //   labelStyle: TextStyle(
    //     fontSize: 18,
    //     fontWeight: FontWeight.bold,
    //   ),
    //   labelOffset: -36,
    //   rotateLabels: false,
    //   selectedColor: Colors.deepOrangeAccent,
    //   context: context,
    // );

    String getFormattedDate(DateTime date) {
      return '${date.day}-${date.month}-${date.year}';
    }

    String aroundMinutes(int minutes) {
      int roundedMinutes = ((minutes / 15).round() * 15) % 60;
      return roundedMinutes < 10 ? '0$roundedMinutes' : roundedMinutes.toString();
    }

    String getFormattedTime(DateTime date) {
      int hour = date.hour;
      int minute = date.minute;
      String hourString = hour < 10 ? '0$hour' : hour.toString();
      String minuteString = aroundMinutes(minute);
      return '$hourString:$minuteString';
    }

    String getStartDateText() {
      return isSchoolCamp
          ? 'Inizia il ${getFormattedDate(startDate)}'
          : 'Giorno: ${getFormattedDate(startDate)}';
    }

    String getEndDateText() {
      return isSchoolCamp
          ? 'Finisce il ${getFormattedDate(endDate)}'
          : 'Orario: ${getFormattedTime(startDate)} - ${getFormattedTime(endDate)}';
    }

    return Flexible(
      child: Row(
        children: [
          Flexible(
            child: TextButton(
              onPressed: isSchoolCamp ? dateRangePicker : dateTimePicker,
              child: Text(
                getStartDateText(),
                style: Theme.of(context).primaryTextTheme.labelMedium,
              ),
            ),
          ),
          SizedBox(width: 20),
          Flexible(
            child: TextButton(
              onPressed: timeRangePicker,
              child: Text(
                getEndDateText(),
                style: Theme.of(context).primaryTextTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
