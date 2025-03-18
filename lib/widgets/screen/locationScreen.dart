import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/location.dart';
import 'package:oservice/entities/person.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/card/LocationCard.dart';

class LocationScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const LocationScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late FirebaseHelper firebaseHelper;
  late Person person;
  List<Location> locationList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadEntities(); // Carica collaboratori all'inizio
  }

  Future<void> _loadEntities() async {
    try {
      locationList = await FirebaseHelper.getAllLocations();
    } catch (e) {
      print("Errore durante il caricamento dei luoghi: $e");
    } finally {
      setState(() {
        isLoading = false; // Imposta isLoading a false dopo il caricamento
      });
    }
  }

  Future<void> _fetchLocations() async {
    try {
      List<Location> locations = await FirebaseHelper.getAllLocations();
      setState(() {
        locationList = locations;
      });
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero delle locations: $e'));
    }
  }

  void showErrorSnackbar(Exception exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Errore!',
          message: 'Errore durante il recupero delle posizioni: $exception',
          contentType: ContentType.failure,
        ),
      ),
    );
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
                itemCount: locationList.length,
                itemBuilder: (context, index) {
                  return LocationCard(changeTab: widget.changeTab,
                      menu: widget.menu,
                      location: locationList[index],
                      refreshLocations: _fetchLocations
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
                  widget.changeTab(Menu.AGGIUNGI_LOCATION.index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
