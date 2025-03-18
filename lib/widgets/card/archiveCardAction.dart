import 'dart:collection';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/google/calendarClient.dart';
import 'package:oservice/utils/responseHandler.dart';

class ArchiveCardAction extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Lesson lesson;
  final Function refreshLessons;

  const ArchiveCardAction({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.lesson,
    required this.refreshLessons,
  });

  @override
  _ArchiveCardActionState createState() => _ArchiveCardActionState();
}

class _ArchiveCardActionState extends State<ArchiveCardAction> {
  void showSuccessSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$title rimossa correttamente!',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showErrorSnackbar(Exception exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Errore!',
          message: 'Errore durante l\'eliminazione della lezione: $exception',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.warning_rounded, color: Colors.red.shade700),
          title: Text('Conferma'),
          content: Text(
              'Sei sicuro di voler eliminare la lezione ${widget.lesson.title}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, annulla'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseHelper.removeCollaboratorsLesson(
                    widget.lesson.collaborators, widget.lesson.id);
                Result<String> result =
                    await FirebaseHelper.deleteLesson(widget.lesson.id);
                Result<String> resultCalendarApi =
                    await CalendarClient.deleteEvent(
                        widget.lesson.entity.calendarId, widget.lesson.eventId);
                await widget.refreshLessons();
                Navigator.of(context).pop();
                if (result is Success && resultCalendarApi is Success) {
                  showSuccessSnackbar(widget.lesson.title);
                } else {
                  print(
                      "Errore durante l'eliminazione della lezione: ${(result as Error).exception}");
                  showErrorSnackbar((result as Error).exception);
                }
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> duplicateLesson() async {
    Lesson lesson2duplicate = widget.lesson
      ..id = ""
      ..exercises = widget.lesson.exercises
      ..collaborators = widget.lesson.collaborators
      ..isInCalendar = false
      ..payments = HashMap();
    FirebaseHelper firebaseHelper = FirebaseHelper.initialize();
    await FirebaseHelper.setIsLessonSaved(true);
    await firebaseHelper.saveLesson(lesson2duplicate);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.lesson.isRegistered()
            ? SizedBox(
                width: 0,
              )
            : IconButton(
                onPressed: () async {
                  await FirebaseHelper.setIdRegisteredLesson(widget.lesson.id);
                  widget.changeTab(Menu.CONVALIDA_LEZIONE.index);
                  Menu.screenRouting(
                      Menu.CONVALIDA_LEZIONE.index, widget.changeTab, widget.menu);
                },
                icon: Icon(Icons.done_rounded,
                    color: Theme.of(context).primaryColorLight),
                tooltip: 'Registra'),
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).primaryColorLight),
          onPressed: () async {
            await FirebaseHelper.setIsLessonEditing(true);
            await FirebaseHelper.setIdSavedLesson(widget.lesson.id);
            widget.changeTab(Menu.AGGIUNGI_LEZIONE.index);
            Menu.screenRouting(
                Menu.AGGIUNGI_LEZIONE.index, widget.changeTab, widget.menu);
          },
          tooltip: 'Modifica',
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).primaryColorLight),
          onPressed: () {
            showConfirmDialog();
          },
          tooltip: 'Elimina',
        ),
        IconButton(
          icon: Icon(Icons.control_point_duplicate_rounded,
              color: Theme.of(context).primaryColorLight),
          onPressed: () async {
            await duplicateLesson();
            widget.changeTab(Menu.AGGIUNGI_LEZIONE.index);
            Menu.screenRouting(
                Menu.AGGIUNGI_LEZIONE.index, widget.changeTab, widget.menu);
          },
          tooltip: 'Duplica',
        ),
      ],
    );
  }
}
