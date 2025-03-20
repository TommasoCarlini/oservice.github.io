import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_codice_fiscale/codice_fiscale.dart';
import 'package:flutter_codice_fiscale/dao/city_dao.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/collaboratorExtended.dart';
import 'package:oservice/entities/taxinfo.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

class AddTaxInfoScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const AddTaxInfoScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _AddTaxInfoScreenState createState() => _AddTaxInfoScreenState();
}

class _AddTaxInfoScreenState extends State<AddTaxInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController fiscalCodeController = TextEditingController();
  bool maleController = false;
  bool femaleController = false;

  String collaboratorId = "";

  FirebaseHelper firebaseHelper = FirebaseHelper.initialize();

  @override
  void initState() {
    super.initState();
    _fetchCollaborator();
  }

  Future<void> _fetchCollaborator() async {
    try {
      String collaboratorId = await FirebaseHelper.getIdSavedTaxInfo();
      Collaborator collaborator =
          await FirebaseHelper.getCollaboratorById(collaboratorId);
      populateFields(collaborator);
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero del collaboratore: $e'));
    }
  }

  void populateFields(Collaborator collaborator) {
    setState(() {
      collaboratorId = collaborator.id;
      if (collaborator.name.split(" ").length < 3) {
        nameController.text = collaborator.name.split(" ").first;
        surnameController.text = collaborator.name.split(" ").last;
      }
    });
  }

  void changeScreen() {
    if (Menu.fromIndex(widget.menu.index) == Menu.COLLABORATORI) {
      widget.changeTab(Menu.COLLABORATORI.index);
    } else if (Menu.fromIndex(widget.menu.index) == Menu.HOME) {
      widget.changeTab(Menu.HOME.index);
    } else {
      widget.changeTab(Menu.PAYMENTS.index);
    }
  }

  void showSuccessSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: 'Aggiunte le informazioni di fatturazione per $name!',
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
          message: 'Errore durante l\'aggiunta delle informazioni di fatturazione: $exception',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void showFiscalCodeErrorSnackbar(Exception exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Errore!',
          message: 'Errore durante il recupero del codice fiscale: $exception',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  DateTime extractDate(String date) {
    List<String> dateList = date.split("/");
    if (dateList.length != 3) {
      throw Exception("Data non valida, deve essere nel formato gg/mm/aaaa");
    }
    return DateTime(
        int.parse(dateList[2]), int.parse(dateList[1]), int.parse(dateList[0]));
  }

  Future<void> addTaxInfo() async {
    final String name = nameController.text;
    final String surname = surnameController.text;
    final String address = addressController.text;
    final String zip = zipCodeController.text;
    final String city = cityController.text;
    final String birthPlace = birthPlaceController.text;
    final String birthDate = birthDateController.text;
    final String gender = maleController ? "M" : "F";
    final String fiscalCode = fiscalCodeController.text;

    TaxInfo taxInfo = TaxInfo(
        name: name,
        surname: surname,
        address: address,
        zipCode: zip,
        city: city,
        birthPlace: birthPlace,
        birthDate: birthDate,
        gender: gender,
        collaboratorId: collaboratorId,
        fiscalCode: fiscalCode);

    Result<String> result = await firebaseHelper.addTaxInfo(taxInfo);

    if (result is Success) {
      showSuccessSnackbar(name);
      await FirebaseHelper.setIsCollaboratorSaved(false);
      changeScreen();
    } else {
      showErrorSnackbar((result as Error).exception);
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
                Navigator.of(context).pop();
                widget.changeTab(Menu.PAYMENTS.index);
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  void evaluateFiscalCode() {
    try {
      String name = nameController.text;
      String surname = surnameController.text;
      String birthPlace = birthPlaceController.text;
      String birthDate = birthDateController.text;
      CodiceFiscaleGender gender =
          maleController ? CodiceFiscaleGender.M : CodiceFiscaleGender.F;

      if (name.isEmpty || surname.isEmpty || birthPlace.isEmpty || birthDate.isEmpty || (!maleController && !femaleController)) {
        throw Exception("Compila tutti i campi obbligatori");
      }

      CodiceFiscale fiscalCode = CodiceFiscale(
          firstName: name,
          lastName: surname,
          birthCity: CityDao().getCityByName(birthPlace),
          gender: gender,
          birthDate: extractDate(birthDate));

      fiscalCodeController.text = fiscalCode.fiscalCode;
    } on Exception catch (e) {
      showFiscalCodeErrorSnackbar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(42.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Aggiungi informazioni di fatturazione',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  Expanded(
                    child: TextFormField(
                      controller: surnameController,
                      decoration: InputDecoration(
                        labelText: 'Cognome',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  Row(
                    children: [
                      Text(
                        "Sesso",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "M",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Checkbox(
                        value: maleController,
                        onChanged: (value) {
                          setState(() {
                            maleController = value ?? false;
                            femaleController = !maleController ?? false;
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        "F",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Checkbox(
                        value: femaleController,
                        onChanged: (value) {
                          setState(() {
                            femaleController = value ?? false;
                            maleController = !femaleController ?? false;
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Indirizzo residena',
                        prefixIcon: Icon(Icons.home_rounded),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  Expanded(
                    child: TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'Città',
                        prefixIcon: Icon(Icons.location_city_rounded),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  SizedBox(
                    width: 160,
                    child: TextFormField(
                      controller: zipCodeController,
                      decoration: InputDecoration(
                        labelText: 'CAP',
                        prefixIcon: Icon(Icons.pin),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: birthPlaceController,
                      decoration: InputDecoration(
                        labelText: 'Luogo di nascita',
                        prefixIcon: Icon(Icons.apartment_rounded),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: birthDateController,
                      decoration: InputDecoration(
                        labelText: 'Data di nascita',
                        prefixIcon: Icon(Icons.date_range_rounded),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: fiscalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Codice fiscale',
                            prefixIcon: Icon(Icons.recent_actors_rounded),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          evaluateFiscalCode();
                        },
                        icon: Icon(Icons.refresh_rounded),
                        tooltip: "Calcola",
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 80),
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
                      onPressed: addTaxInfo,
                      child: Text(
                        'Aggiungi informazioni',
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
