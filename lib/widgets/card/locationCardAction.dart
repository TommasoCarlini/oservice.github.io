import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/location.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

class LocationCardAction extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Location location;
  final Function refreshLocations;

  const LocationCardAction({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.location,
    required this.refreshLocations,
  });

  @override
  State<LocationCardAction> createState() => _LocationCardActionState();
}

class _LocationCardActionState extends State<LocationCardAction> {
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
              'Sei sicuro di voler rimuovere ${widget.location.title} dai luoghi?'),
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
                        widget.location.id, 'location');
                List<Entity> entitiesByLocation =
                    await FirebaseHelper.getEntitiesByField(
                        widget.location.id, 'location');
                Navigator.of(context).pop();
                if (lessonsByLocation.isNotEmpty || entitiesByLocation.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Azione bloccata!',
                        message:
                            'Non puoi eliminare un luogo con lezioni o entità associate',
                        contentType: ContentType.failure,
                      ),
                    ),
                  );
                  return;
                } else {
                  Result<String> result =
                      await FirebaseHelper.deleteLocation(widget.location.id);
                  if (result is Success) {
                    showSuccessSnackbar(widget.location.title);
                  } else {
                    showErrorSnackbar((result as Error).exception);
                  }
                  await widget.refreshLocations();
                  widget.changeTab(Menu.LUOGHI.index);
                  Menu.screenRouting(
                      Menu.LUOGHI.index, widget.changeTab, widget.menu);
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
            await FirebaseHelper.setIsLocationSaved(true);
            await FirebaseHelper.setIdSavedLocation(widget.location.id);
            widget.changeTab(Menu.AGGIUNGI_LOCATION.index);
            Menu.screenRouting(Menu.AGGIUNGI_LOCATION.index,
                widget.changeTab, widget.menu);
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
