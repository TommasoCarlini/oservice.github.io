import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget HomeScreenHeader(double width, bool isColabComplete,
    Function showOnlyColab, Function loadMoreLessons) {
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
                  onPressed: () => loadMoreLessons(),
                  child: Text(
                    "Carica altri 7 giorni",
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca',
                hintStyle: TextStyle(color: Colors.indigo),
                prefixIcon: Icon(Icons.search, color: Colors.indigo),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
          // button for filter
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
