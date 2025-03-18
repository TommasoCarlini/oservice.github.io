import 'package:flutter/material.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/widgets/card/collaboratorCardAction.dart';

class CollaboratorCard extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Collaborator collaborator;
  final Function refreshCollaborators;

  const CollaboratorCard({
    super.key,
    required this.collaborator,
    required this.changeTab,
    required this.menu,
    required this.refreshCollaborators,
  });

  @override
  State<CollaboratorCard> createState() => _CollaboratorCardState();
}

class _CollaboratorCardState extends State<CollaboratorCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Theme.of(context).cardColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Row(
          children: [
            Text(
              widget.collaborator.name,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            widget.collaborator.englishSpeaker
                ? Icon(
                    Icons.language_rounded,
                    color: Theme.of(context).primaryColorLight,
                  )
                : SizedBox(
                    width: 0,
                  ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Theme.of(context).primaryColorLight),
                SizedBox(width: 10),
                Text(
                  widget.collaborator.phone,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.mail, color: Theme.of(context).primaryColorLight),
                SizedBox(width: 10),
                Text(
                  widget.collaborator.mail,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ],
            ),
          ],
        ),
        trailing: CollaboratorCardAction(
            changeTab: widget.changeTab,
            menu: widget.menu,
            collaborator: widget.collaborator,
            refreshCollaborators: widget.refreshCollaborators),
      ),
    );
  }
}
