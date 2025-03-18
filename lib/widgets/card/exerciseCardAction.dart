import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/exercise.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

class ExerciseCardAction extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Exercise exercise;
  final Function refreshExercises;

  const ExerciseCardAction({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.exercise,
    required this.refreshExercises,
  });

  @override
  State<ExerciseCardAction> createState() => _ExerciseCardActionState();
}

class _ExerciseCardActionState extends State<ExerciseCardAction> {
  void showSuccessSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$title rimosso correttamente!',
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
          message:
          'Errore durante l\'eliminazione del collaboratore: $exception',
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
              'Sei sicuro di voler rimuovere ${widget.exercise.title} dai luoghi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, annulla'),
            ),
            TextButton(
              onPressed: () async {
                List<Lesson> lessonsByLocation =
                await FirebaseHelper.getLessonsByField(
                    widget.exercise.id, 'exercises');
                Navigator.of(context).pop();
                if (lessonsByLocation.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Azione bloccata!',
                        message:
                        'Non puoi eliminare un luogo con lezioni associate',
                        contentType: ContentType.failure,
                      ),
                    ),
                  );
                  return;
                } else {
                  Result<String> result =
                  await FirebaseHelper.deleteLocation(widget.exercise.id);
                  if (result is Success) {
                    showSuccessSnackbar(widget.exercise.title);
                  } else {
                    showErrorSnackbar((result as Error).exception);
                  }
                  await widget.refreshExercises();
                  widget.changeTab(Menu.ESERCIZI.index);
                  Menu.screenRouting(
                      Menu.ESERCIZI.index, widget.changeTab, widget.menu);
                }
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).primaryColorLight),
          onPressed: () async {
            await FirebaseHelper.setIsExerciseSaved(true);
            await FirebaseHelper.setIdSavedExercise(widget.exercise.id);
            widget.changeTab(Menu.AGGIUNGI_ESERCIZIO.index);
            Menu.screenRouting(Menu.AGGIUNGI_ESERCIZIO.index,
                widget.changeTab, widget.menu);
            // Aggiungi la logica per l'azione di modifica
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).primaryColorLight),
          onPressed: () async {
            showConfirmDialog();
          },
        ),
      ],
    );
  }
}
