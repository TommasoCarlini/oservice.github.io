import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/person.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/card/entityCard.dart';

class EntityScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const EntityScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _EntityScreenState createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  late FirebaseHelper firebaseHelper;
  late Person person;
  List<Entity> entityList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadEntities(); // Carica collaboratori all'inizio
  }

  Future<void> _loadEntities() async {
    try {
      entityList = await FirebaseHelper.getAllEntities();
      entityList.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print("Errore durante il caricamento degli enti: $e");
    } finally {
      setState(() {
        isLoading = false; // Imposta isLoading a false dopo il caricamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;

    // Mostra un indicatore di caricamento finché i dati non sono stati caricati
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // Dopo il caricamento, mostra il contenuto principale
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
              // Usa Expanded per adattare la lista allo spazio disponibile
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                itemCount: entityList.length,
                itemBuilder: (context, index) {
                  return EntityCard(changeTab: widget.changeTab,
                    menu: widget.menu,
                    entity: entityList[index],
                    refreshEntities: _loadEntities
                  );
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
                  widget.changeTab(Menu.AGGIUNGI_ENTE.index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
