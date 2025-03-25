import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/taxinfo.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CollaboratorCardAction extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Collaborator collaborator;
  final Function refreshCollaborators;

  const CollaboratorCardAction({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.collaborator,
    required this.refreshCollaborators,
  });

  @override
  State<CollaboratorCardAction> createState() => _CollaboratorCardActionState();
}

class _CollaboratorCardActionState extends State<CollaboratorCardAction> {
  bool areTaxIndoComplete = false;

  @override
  void initState() {
    super.initState();
    checkTaxInfo();
  }

  Future<void> checkTaxInfo() async {
    TaxInfo? taxInfo = await FirebaseHelper.getTaxInfoByCollaboratorId(widget.collaborator.id);
    if (taxInfo == null) {
      setState(() {
        areTaxIndoComplete = false;
      });
    }
    else {
      setState(() {
        areTaxIndoComplete = true;
      });
    }
  }

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
              'Sei sicuro di voler rimuovere ${widget.collaborator.name} dai collaboratori?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, annulla'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Result<String> result =
                await FirebaseHelper.deleteCollaborator(widget.collaborator.id);
                if (result is Success) {
                  showSuccessSnackbar(widget.collaborator.name);
                } else {
                  showErrorSnackbar((result as Error).exception);
                }
                await widget.refreshCollaborators();
                widget.changeTab(Menu.COLLABORATORI.index);
                Menu.screenRouting(
                    Menu.COLLABORATORI.index, widget.changeTab, widget.menu);
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
        areTaxIndoComplete ? Container() : Tooltip(
          message: "Aggiungi informazioni di fatturazione",
          child: IconButton(
            icon: Icon(Icons.recent_actors_rounded, color: Theme.of(context).primaryColorLight),
            onPressed: () async {
              await FirebaseHelper.setIdSavedTaxInfo(widget.collaborator.id);
              widget.changeTab(Menu.TAX_INFO.index);
              Menu.screenRouting(
                  Menu.TAX_INFO.index, widget.changeTab, widget.menu);
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).primaryColorLight),
          onPressed: () async {
            await FirebaseHelper.setIsCollaboratorSaved(true);
            await FirebaseHelper.setIdSavedCollaborator(widget.collaborator.id);
            widget.changeTab(Menu.AGGIUNGI_COLLABORATORE.index);
            Menu.screenRouting(
                Menu.AGGIUNGI_COLLABORATORE.index, widget.changeTab, widget.menu);
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
