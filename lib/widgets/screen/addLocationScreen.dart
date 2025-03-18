import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_url_extractor/google_maps_url_extractor.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/coordinates.dart';
import 'package:oservice/entities/location.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

class AddLocationScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const AddLocationScreen({
    Key? key,
    required this.changeTab,
    required this.menu,
  }) : super(key: key);

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController hrefController = TextEditingController();
  final TextEditingController coordinatesLatitudeController =
      TextEditingController();
  final TextEditingController coordinatesLongitudeController =
      TextEditingController();

  FirebaseHelper firebaseHelper = FirebaseHelper.initialize();

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchIsEditMode();
  }

  Future<void> _fetchSavedLocation() async {
    try {
      String savedLocationId = await FirebaseHelper.getIdSavedLocation();
      Location savedLocation =
          await FirebaseHelper.getLocationById(savedLocationId);
      populateFields(savedLocation);
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero della posizione salvata: $e'));
    }
  }

  Future<void> _fetchIsEditMode() async {
    bool isEditMode = await FirebaseHelper.getIsEditLocationMode();
    setState(() {
      if (isEditMode) {
        _fetchSavedLocation();
      }
      this.isEditMode = isEditMode;
    });
  }

  void populateFields(Location savedLocation) {
    setState(() {
      titleController.text = savedLocation.title;
      addressController.text = savedLocation.address;
      cityController.text = savedLocation.city;
      hrefController.text = savedLocation.href;
      coordinatesLatitudeController.text = savedLocation.coordinates.latitude;
      coordinatesLongitudeController.text = savedLocation.coordinates.longitude;
    });
  }

  void showSuccessSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$name aggiuna alle posizioni!',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showSuccessSnackbarImportLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Successo!',
          message: 'Posizione importata correttamente!',
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
          message: 'Errore durante l\'aggiunta del collaboratore: $exception',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void showErrorSnackbarEmptyHref() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Attenzione!',
          message: 'Inserire un link per importare le informazioni',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void showErrorSnackbarNotValidHref() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Attenzione!',
          message:
              'Link non valido. Assicurati di inserire un link esteso di Google Maps',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  Future<Coordinates> extractCoordinates() async {
    Map<String, double>? expandedUrl =
        await GoogleMapsUrlExtractor.processGoogleMapsUrl(hrefController.text);
    if (expandedUrl != null) {
      return Coordinates(
        latitude: expandedUrl["latitude"]!.toString(),
        longitude: expandedUrl["longitude"]!.toString(),
      );
    } else {
      return extractCoordinatesFromUrl(hrefController.text);
    }
  }

  Coordinates extractCoordinatesFromUrl(String url) {
    final latLngPattern = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');

    final match = latLngPattern.firstMatch(url);

    if (match != null) {
      final latitude = match.group(1);
      final longitude = match.group(2);
      return Coordinates(latitude: latitude!, longitude: longitude!);
    } else {
      throw Exception('Coordinate non trovate');
    }
  }

  void showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Conferma'),
          content: Text('Tutte le modifiche andranno perse'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, voglio restare'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseHelper.setIsLocationSaved(false);
                Navigator.of(context).pop();
                widget.changeTab(Menu.IMPOSTAZIONI.index);
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addLocation() async {
    Location location = Location(
      title: titleController.text,
      address: addressController.text,
      city: cityController.text,
      href: hrefController.text,
      coordinates: Coordinates(
        latitude: coordinatesLatitudeController.text,
        longitude: coordinatesLongitudeController.text,
      ),
    );

    Result<String> result = await firebaseHelper.addLocation(location);

    if (result is Success<String>) {
      showSuccessSnackbar(titleController.text);
      widget.changeTab(Menu.HOME.index);
    } else if (result is Error<String>) {
      showErrorSnackbar((result as Error).exception);
    }
  }

  Future<void> updateLocation() async {
    Location location = Location(
      title: titleController.text,
      address: addressController.text,
      city: cityController.text,
      href: hrefController.text,
      coordinates: Coordinates(
        latitude: coordinatesLatitudeController.text,
        longitude: coordinatesLongitudeController.text,
      ),
    );

    String locationId = await FirebaseHelper.getIdSavedLocation();
    Result<String> result =
        await firebaseHelper.updateLocation(location..id = locationId);

    if (result is Success<String>) {
      showSuccessSnackbar(titleController.text);
      widget.changeTab(Menu.HOME.index);
    } else if (result is Error<String>) {
      showErrorSnackbar((result as Error).exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Aggiungi una nuova posizione",
                style: Theme.of(context).primaryTextTheme.titleMedium,
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Titolo'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Indirizzo'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Città'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hrefController,
                      decoration: InputDecoration(labelText: 'Link'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      child: TextButton(
                          onPressed: () async {
                            if (hrefController.text.isEmpty) {
                              showErrorSnackbarEmptyHref();
                            } else {
                              try {
                                final Coordinates coordinates =
                                    await extractCoordinates();
                                coordinatesLatitudeController.text =
                                    coordinates.latitude;
                                coordinatesLongitudeController.text =
                                    coordinates.longitude;
                                Map<String, String> location =
                                    await coordinates.reverseGeocoding();
                                addressController.text = location["address"]!;
                                cityController.text = location["city"]!;
                                showSuccessSnackbarImportLocation();
                              } catch (e) {
                                showErrorSnackbarNotValidHref();
                              }
                            }
                          },
                          child: Text("Importa da Google Maps")))
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: coordinatesLatitudeController,
                      decoration: InputDecoration(labelText: 'Latitudine'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: coordinatesLongitudeController,
                      decoration: InputDecoration(labelText: 'Longitudine'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        surfaceTintColor: Colors.blue.shade900,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        showConfirmDialog();
                      },
                      child: Text(
                        'Annulla',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        textStyle: TextStyle(color: Colors.white),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isEditMode ? updateLocation : addLocation,
                      child: isEditMode
                          ? Text(
                              'Salva la posizione',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Aggiungi nuova posizione',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
