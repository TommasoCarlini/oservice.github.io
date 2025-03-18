import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/google/calendarClient.dart';
import 'package:oservice/utils/responseHandler.dart';

class EntityCardAction extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Entity entity;
  final Function refreshEntities;

  const EntityCardAction({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.entity,
    required this.refreshEntities,
  });

  @override
  _EntityCardActionState createState() => _EntityCardActionState();
}

class _EntityCardActionState extends State<EntityCardAction> {
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
          message: 'Errore durante l\'eliminazione dell\'ente: $exception',
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
              'Sei sicuro di voler eliminare l\'entità ${widget.entity
                  .name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, annulla'),
            ),
            TextButton(
              onPressed: () async {
                List<Lesson> lessonsByEntity = await FirebaseHelper.getLessonsByField(
                    widget.entity.id, 'entity');
                Navigator.of(context).pop();
                if (lessonsByEntity.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Azione bloccata!',
                        message: 'Non puoi eliminare un ente con lezioni associate',
                        contentType: ContentType.failure,
                      ),
                    ),
                  );
                  return;
                }
                else {
                  Result<String> resultCalendarApi =
                  await CalendarClient.deleteCalendar(
                      widget.entity.calendarId);
                  Result<String> result = await FirebaseHelper.deleteEntity(widget.entity.id);
                  if (result is Success && resultCalendarApi is Success) {
                    showSuccessSnackbar(widget.entity.name);
                  } else {
                    showErrorSnackbar((result as Error).exception);
                  }
                  await widget.refreshEntities();
                  widget.changeTab(Menu.ENTI.index);
                  Menu.screenRouting(
                      Menu.ENTI.index, widget.changeTab, widget.menu);
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
          icon: Icon(Icons.edit, color: Theme
              .of(context)
              .primaryColorLight),
          onPressed: () async {
            await FirebaseHelper.setIsEntitySaved(true);
            await FirebaseHelper.setIdSavedEntity(widget.entity.id);
            widget.changeTab(Menu.AGGIUNGI_ENTE.index);
            Menu.screenRouting(
                Menu.AGGIUNGI_ENTE.index, widget.changeTab, widget.menu);
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme
              .of(context)
              .primaryColorLight),
          onPressed: () async {
            showConfirmDialog();
          },
        ),
      ],
    );
  }
}
