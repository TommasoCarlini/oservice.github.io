import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/location.dart'; // Aggiunto: Location entity
import 'package:oservice/entities/person.dart';
import 'package:oservice/enums/entityType.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/google/calendarClient.dart';
import 'package:oservice/utils/responseHandler.dart';

class AddEntityScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const AddEntityScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _AddEntityScreenState createState() => _AddEntityScreenState();
}

class _AddEntityScreenState extends State<AddEntityScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController ownerMailController = TextEditingController();
  final TextEditingController refereeNameController = TextEditingController();
  final TextEditingController refereePhoneController = TextEditingController();
  final TextEditingController refereeMailController = TextEditingController();
  final TextEditingController secretaryNameController = TextEditingController();
  final TextEditingController secretaryPhoneController =
      TextEditingController();
  final TextEditingController secretaryMailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  EntityType entityTypeController = EntityType.SCHOOL;
  FirebaseHelper firebaseHelper = FirebaseHelper.initialize();
  Color selectedColor = Colors.grey;

  Location? selectedLocation;

  List<Location> allLocations = [];

  bool isLoading = false;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchIsEditMode();
  }

  Future<void> _fetchLocations() async {
    try {
      List<Location> locations = await FirebaseHelper.getAllLocations();
      locations.sort((a, b) => a.title.compareTo(b.title));
      setState(() {
        allLocations = locations;
      });
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero delle locations: $e'));
    }
  }

  Future<void> _fetchSavedEntity() async {
    try {
      String savedEntityId = await FirebaseHelper.getIdSavedEntity();
      Entity savedEntity = await FirebaseHelper.getEntityById(savedEntityId);
      populateFields(savedEntity);
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero dell\'entità salvata: $e'));
    }
  }

  Future<void> _fetchIsEditMode() async {
    bool isEditMode = await FirebaseHelper.getIsEditEntityMode();
    setState(() {
      if (isEditMode) {
        _fetchSavedEntity();
      }
      this.isEditMode = isEditMode;
    });
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void populateFields(Entity savedEntity) {
    setState(() {
      nameController.text = savedEntity.name;
      colorController.text = savedEntity.color;
      ownerNameController.text = savedEntity.owner.name;
      ownerPhoneController.text = savedEntity.owner.phone;
      ownerMailController.text = savedEntity.owner.mail;
      refereeNameController.text = savedEntity.referee.name;
      refereePhoneController.text = savedEntity.referee.phone;
      refereeMailController.text = savedEntity.referee.mail;
      secretaryNameController.text = savedEntity.secretary.name;
      secretaryPhoneController.text = savedEntity.secretary.phone;
      secretaryMailController.text = savedEntity.secretary.mail;
      entityTypeController = savedEntity.type;
      selectedLocation = savedEntity.location;
      selectedColor = fromHex(savedEntity.color);
    });
  }

  void showSuccessSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$name aggiunto agli enti!',
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
          message: exception.toString(),
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  Future<void> addEntity() async {
    if (selectedLocation == null || selectedLocation!.id.isEmpty) {
      showErrorSnackbar(Exception('Nessuna location valida selezionata.'));
      return;
    }

    if (nameController.text.isEmpty) {
      showErrorSnackbar(Exception('Il nome dell\'ente non può essere vuoto.'));
      return;
    }

    Entity entity = Entity(
      name: nameController.text,
      color: colorController.text,
      owner: entityTypeController == EntityType.SCHOOL
          ? Person(
              name: ownerNameController.text,
              mail: ownerMailController.text,
              phone: ownerPhoneController.text,
            )
          : Person.dummyPerson(),
      referee: Person(
        name: refereeNameController.text,
        mail: refereeMailController.text,
        phone: refereePhoneController.text,
      ),
      secretary: entityTypeController == EntityType.SCHOOL
          ? Person(
              name: secretaryNameController.text,
              mail: secretaryMailController.text,
              phone: secretaryPhoneController.text,
            )
          : Person.dummyPerson(),
      type: entityTypeController,
      lessons: [],
    )..location = selectedLocation!;

    setState(() {
      isLoading = true;
    });
    Result<String> calendarApiResult = await CalendarClient.addCalendar(
        entity.mapToCalendar(), colorController.text);
    Result<String> result = await firebaseHelper
        .addEntity(entity..calendarId = (calendarApiResult as Success).data);
    setState(() {
      isLoading = false;
    });

    if (result is Success) {
      showSuccessSnackbar(nameController.text);
      widget.changeTab(Menu.ENTI.index);
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  Future<void> updateEntity() async {
    if (selectedLocation == null || selectedLocation!.id.isEmpty) {
      showErrorSnackbar(Exception('Nessuna location valida selezionata.'));
      return;
    }

    if (nameController.text.isEmpty) {
      showErrorSnackbar(Exception('Il nome dell\'ente non può essere vuoto.'));
      return;
    }

    Entity newEntity = Entity(
      name: nameController.text,
      color: colorController.text,
      owner: entityTypeController == EntityType.SCHOOL
          ? Person(
              name: ownerNameController.text,
              mail: ownerMailController.text,
              phone: ownerPhoneController.text,
            )
          : Person.dummyPerson(),
      referee: Person(
        name: refereeNameController.text,
        mail: refereeMailController.text,
        phone: refereePhoneController.text,
      ),
      secretary: entityTypeController == EntityType.SCHOOL
          ? Person(
              name: secretaryNameController.text,
              mail: secretaryMailController.text,
              phone: secretaryPhoneController.text,
            )
          : Person.dummyPerson(),
      type: entityTypeController,
      lessons: [],
    )..location = selectedLocation!;

    setState(() {
      isLoading = true;
    });
    Entity oldEntity = await FirebaseHelper.getEntityById(
        await FirebaseHelper.getIdSavedEntity());
    Result<String> calendarApiResult = await CalendarClient.updateCalendar(
        newEntity.mapToCalendar(), oldEntity.calendarId, colorController.text);
    Result<String> result = await firebaseHelper.updateEntity(newEntity
      ..calendarId = (calendarApiResult as Success).data
      ..id = oldEntity.id);
    setState(() {
      isLoading = false;
    });

    if (result is Success) {
      showSuccessSnackbar(nameController.text);
      widget.changeTab(Menu.ENTI.index);
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  void pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona un colore'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                  colorController.text = toHex(selectedColor);
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                await FirebaseHelper.setIsEntitySaved(false);
                Navigator.of(context).pop();
                widget.changeTab(Menu.ENTI.index);
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
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Nuovo ente',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: pickColor,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: selectedColor,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<EntityType>(
                      borderRadius: BorderRadius.circular(16),
                      decoration: InputDecoration(
                        labelText: 'Tipo di Ente',
                        border: UnderlineInputBorder(),
                      ),
                      value: entityTypeController,
                      items: EntityType.values()
                          .map((entityItem) => DropdownMenuItem<EntityType>(
                                value: entityItem,
                                child: Text(entityItem.type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          entityTypeController = value ?? EntityType.SCHOOL;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    child: DropdownMenu<Location>(
                      width: 300,
                      inputDecorationTheme: InputDecorationTheme(
                        border: UnderlineInputBorder(),
                      ),
                      hintText: 'Seleziona una posizione',
                      controller: locationController,
                      enableFilter: true,
                      dropdownMenuEntries: allLocations.map((location) {
                        return DropdownMenuEntry<Location>(
                          value: location,
                          label: location.title,
                        );
                      }).toList(),
                      searchCallback: (entries, query) {
                        final String searchText =
                            locationController.value.text.toLowerCase();
                        if (searchText.isEmpty) {
                          return null;
                        }
                        final int index = entries.indexWhere(
                            (DropdownMenuEntry<Location> entry) =>
                                entry.label.toLowerCase().contains(searchText));
                        return index != -1 ? index : null;
                      },
                      onSelected: (Location? location) {
                        if (location != null) {
                          setState(() {
                            selectedLocation = location;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                      onPressed: () {
                        widget.changeTab(Menu.AGGIUNGI_LOCATION.index);
                      },
                      icon: Icon(Icons.add_location_alt_rounded)),
                  SizedBox(width: 20),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Referente",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: refereeNameController,
                      decoration: InputDecoration(
                        labelText: 'Nome referente',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    child: TextFormField(
                      controller: refereePhoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefono referente',
                        prefixIcon: Icon(Icons.phone),
                        prefixText: '+39 ',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    child: TextFormField(
                      controller: refereeMailController,
                      decoration: InputDecoration(
                        labelText: 'Email referente',
                        prefixIcon: Icon(Icons.mail),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              if (entityTypeController == EntityType.SCHOOL) ...[
                SizedBox(height: 20),
                Text(
                  "Segreteria",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: secretaryNameController,
                        decoration: InputDecoration(
                          labelText: 'Nome segreteria',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: secretaryPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefono segreteria',
                          prefixIcon: Icon(Icons.phone),
                          prefixText: '+39 ',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: secretaryMailController,
                        decoration: InputDecoration(
                          labelText: 'Email segreteria',
                          prefixIcon: Icon(Icons.mail),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (entityTypeController == EntityType.SCHOOL) ...[
                SizedBox(height: 20),
                Text(
                  "Presidenza",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ownerNameController,
                        decoration: InputDecoration(
                          labelText: 'Nome preside',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: ownerPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefono presidenza',
                          prefixIcon: Icon(Icons.phone),
                          prefixText: '+39 ',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: ownerMailController,
                        decoration: InputDecoration(
                          labelText: 'Email presidenza',
                          prefixIcon: Icon(Icons.mail),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                            fontFamily: 'Montserrat'),
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
                      onPressed: () async {
                        await FirebaseHelper.setIsEntitySaved(false);
                        isEditMode ? updateEntity() : addEntity();
                      },
                      child: Text(
                        isEditMode ? 'Salva modifiche' : 'Aggiungi ente',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
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
