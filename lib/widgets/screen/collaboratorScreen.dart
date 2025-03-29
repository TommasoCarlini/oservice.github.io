import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/person.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/card/collaboratorCard.dart';

class CollaboratorScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const CollaboratorScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _CollaboratorScreenState createState() => _CollaboratorScreenState();
}

class _CollaboratorScreenState extends State<CollaboratorScreen> {
  late FirebaseHelper firebaseHelper;
  late Person person;
  late List<Lesson> lessons;
  List<Collaborator> collaboratorList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadCollaborators();
  }

  Future<void> _loadCollaborators() async {
    try {
      collaboratorList = await FirebaseHelper.getAllCollaborators();
      collaboratorList.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print("Errore durante il caricamento dei collaboratori: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                itemCount: collaboratorList.length,
                itemBuilder: (context, index) {
                  return CollaboratorCard(changeTab: widget.changeTab,
                      menu: widget.menu,
                      collaborator: collaboratorList[index],
                      refreshCollaborators: _loadCollaborators,);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.add_circle_outline_rounded),
                iconSize: width / 40,
                color: Colors.indigo,
                onPressed: () {
                  widget.changeTab(Menu.AGGIUNGI_COLLABORATORE.index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
