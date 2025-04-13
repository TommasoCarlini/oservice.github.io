import 'package:flutter/material.dart';

PreferredSizeWidget HomeScreenHeader(
    double width,
    bool isColabComplete,
    Function showOnlyColab,
    DateTime fromDate,
    DateTime toDate,
    Function loadNextLessons,
    Function dateRangePicker,
    String stepDay,) {
  String getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      title: Row(
        // input text for search
        children: [
          SizedBox(
              width: 250,
              child: TextButton(
                  onPressed: () => loadNextLessons(),
                  child: Text(
                    stepDay == "1" ?
                        "Carica un altro giorno"
                        : "Carica altri $stepDay giorni",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                  ))),
          SizedBox(
            width: 20,
          ),
          Expanded(
              child: TextButton(
                  onPressed: () => dateRangePicker(),
                  child: Text(
                    "${getFormattedDate(fromDate)} - ${getFormattedDate(toDate)}",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                  ))),
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 20,
          ),
          Tooltip(
            message: isColabComplete
                ? "Mostra tutti gli eventi"
                : "Mostra eventi senza collaboratori",
            child: Switch(
              onChanged: (bool value) {
                showOnlyColab(value);
              },
              value: isColabComplete,
              activeColor: Colors.red,
            ),
          ),
          Icon(
            Icons.person_search_rounded,
            color: Colors.indigo,
          ),
        ],
      ));
}
