import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/collaboratorExtended.dart';
import 'package:oservice/entities/taxinfo.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/enums/months.dart';
import 'package:oservice/utils/responseHandler.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:excel/excel.dart';

class AddCollaboratorScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const AddCollaboratorScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _AddCollaboratorScreenState createState() => _AddCollaboratorScreenState();
}

class _AddCollaboratorScreenState extends State<AddCollaboratorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool englishSpeakerController = false;

  bool areTaxIndoComplete = false;

  FirebaseHelper firebaseHelper = FirebaseHelper.initialize();

  bool isEditMode = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIsEditMode();
  }

  Future<void> _fetchSavedCollaborator() async {
    try {
      String savedCollaboratorId =
          await FirebaseHelper.getIdSavedCollaborator();
      Collaborator savedCollaborator =
          await FirebaseHelper.getCollaboratorById(savedCollaboratorId);
      checkTaxInfo(savedCollaborator.id);
      populateFields(savedCollaborator);
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero del collaboratore: $e'));
    }
  }

  Future<void> checkTaxInfo(id) async {
    TaxInfo? taxInfo = await FirebaseHelper.getTaxInfoByCollaboratorId(id);
    if (taxInfo == null) {
      setState(() {
        areTaxIndoComplete = false;
      });
    } else {
      setState(() {
        areTaxIndoComplete = true;
      });
    }
  }

  Future<void> _fetchIsEditMode() async {
    bool isEditMode = await FirebaseHelper.getIsEditCollaboratorMode();
    setState(() {
      if (isEditMode) {
        _fetchSavedCollaborator();
      } else {
        isLoading = false;
      }
      this.isEditMode = isEditMode;
    });
  }

  void populateFields(Collaborator savedCollaborator) {
    setState(() {
      nameController.text = savedCollaborator.name;
      nicknameController.text = savedCollaborator.nickname ?? '';
      mailController.text = savedCollaborator.mail;
      phoneController.text = savedCollaborator.phone;
      englishSpeakerController = savedCollaborator.englishSpeaker;
      isLoading = false;
    });
  }

  void changeScreen() {
    if (Menu.fromIndex(widget.menu.index) == Menu.COLLABORATORI) {
      widget.changeTab(Menu.COLLABORATORI.index);
    } else if (Menu.fromIndex(widget.menu.index) == Menu.HOME) {
      widget.changeTab(Menu.AGGIUNGI_LEZIONE.index);
    } else {
      widget.changeTab(Menu.IMPOSTAZIONI.index);
    }
  }

  void showSuccessSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$name aggiunto ai collaboratori!',
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

  Future<void> addTaxInfo() async {
    final String name = nameController.text;
    final String mail = mailController.text;
    final String phone = phoneController.text;
    final String nickname =
        nicknameController.text.isEmpty ? name : nicknameController.text;

    CollaboratorExtended collaborator = CollaboratorExtended(
      name: name,
      mail: mail.toLowerCase(),
      phone: phone,
      nickname: nickname,
      englishSpeaker: englishSpeakerController,
      payments: [],
      availabilities: [],
    )
      ..nickname = nickname
      ..lessons = [];

    Result<String> result = await firebaseHelper.addCollaborator(collaborator);

    if (result is Success) {
      showSuccessSnackbar(name);
      await FirebaseHelper.setIsCollaboratorSaved(false);
      await FirebaseHelper.setIdSavedTaxInfo((result as Success).data);
      widget.changeTab(Menu.TAX_INFO.index);
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  Future<void> addCollaborator() async {
    final String name = nameController.text;
    final String mail = mailController.text;
    final String phone = phoneController.text;
    final String nickname =
        nicknameController.text.isEmpty ? name : nicknameController.text;

    CollaboratorExtended collaborator = CollaboratorExtended(
      name: name,
      mail: mail.toLowerCase(),
      phone: phone,
      nickname: nickname,
      englishSpeaker: englishSpeakerController,
      payments: [],
      availabilities: [],
    )
      ..nickname = nickname
      ..lessons = [];

    Result<String> result = await firebaseHelper.addCollaborator(collaborator);

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
                await FirebaseHelper.setIsCollaboratorSaved(false);
                Navigator.of(context).pop();
                widget.changeTab(Menu.COLLABORATORI.index);
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<List<dynamic>>> extractExcelData(Uint8List fileBytes) {
    final excel = Excel.decodeBytes(fileBytes);
    Map<String, List<List<dynamic>>> data = {};

    // Itera sui fogli dell'excel
    for (final sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName];
      List<List<dynamic>> sheetData = [];
      for (final row in sheet!.rows) {
        // Estrae il valore di ciascuna cella (eventualmente null)
        List<dynamic> rowData = row.map((cell) => cell?.value).toList();
        sheetData.add(rowData);
      }
      data[sheetName] = sheetData;
    }
    return data;
  }

  Future<void> getInfoFromRow(List<dynamic> row) async {
    String name = "${row[0]} ${row[1]}";
    String mail = "";
    String phone = "";
    String nickname = "";
    bool englishSpeaker =
        row[11].toString().toUpperCase() == 'SI' ? true : false;

    bool isMale(String name) {
      if (name.toLowerCase() == "andrea" ||
          name.toLowerCase() == "mattia" ||
          name.toLowerCase() == "miles") {
        return true;
      }
      return name.split(" ")[0].toLowerCase().endsWith("o") ||
          name.split(" ")[0].toLowerCase().endsWith("e");
    }

    String address = "${row[2]}, ${row[3]}";
    String cap = row[4].toString();
    String city = row[5].toString();
    String fiscalCode = row[6].toString();
    String birthPlace = row[7].toString();
    String day = (row[8]).toString().split(" ")[0];
    String dayString = day.length < 2 ? "0$day" : day;
    int month = Month.fromName((row[8]).toString().split(" ")[1]).number;
    String monthString = month < 10 ? "0$month" : "$month";
    String year = (row[8]).toString().split(" ")[2];
    String birthDate =
        "$dayString/$monthString/$year";
    String gender = isMale(name) ? "M" : "F";

    CollaboratorExtended collaborator = CollaboratorExtended(
      name: name,
      mail: mail,
      phone: phone,
      nickname: nickname,
      englishSpeaker: englishSpeaker,
      payments: [],
      availabilities: [],
    )
      ..nickname = nickname
      ..lessons = [];

    Result<String> result = await firebaseHelper.addCollaborator(collaborator);
    if (result is Success) {
      showSuccessSnackbar(name);
      await FirebaseHelper.setIsCollaboratorSaved(false);
      String collaboratorId = (result as Success).data;
      TaxInfo taxInfo = TaxInfo(
        name: row[1].toString(),
        surname: row[0].toString(),
        collaboratorId: collaboratorId,
        address: address,
        zipCode: cap,
        city: city,
        fiscalCode: fiscalCode,
        birthPlace: birthPlace,
        birthDate: birthDate,
        gender: gender,
      );

      await firebaseHelper.addTaxInfo(taxInfo);
    }
  }

  void pickAndExtractExcelFile() {
    // Crea un input di tipo file
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.xlsx'; // Accetta solo file .xlsx
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();

        reader.onLoadEnd.listen((event) {
          if (reader.result != null) {
            Uint8List fileBytes = reader.result as Uint8List;
            Map<String, List<List<dynamic>>> extractedData =
                extractExcelData(fileBytes);

            extractedData.forEach((sheetName, rows) async {
              print("Foglio: $sheetName");
              for (var row in rows) {
                if (row[0].toString() == "COGNOME") {
                  continue;
                }
                print(row);
                await getInfoFromRow(row);
              }
            });
          }
        });

        reader.readAsArrayBuffer(file);
      }
    });
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
        padding: const EdgeInsets.all(42.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Nuovo collaboratore',
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
                      controller: nicknameController,
                      decoration: InputDecoration(
                        labelText:
                            'Nome da visualizzare (se vuoto, verrà usato il nome)',
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
                      controller: mailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 80),
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefono',
                        prefixIcon: Icon(Icons.phone),
                        prefixText: '+39 ',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Text(
                    "Può fare lezione in inglese?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Checkbox(
                    value: englishSpeakerController,
                    onChanged: (value) {
                      setState(() {
                        englishSpeakerController = value ?? false;
                      });
                    },
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
                    areTaxIndoComplete
                        ? SizedBox()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              textStyle: TextStyle(color: Colors.white),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: addTaxInfo,
                            child: Text(
                              'Aggiungi informazioni di fatturazione',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  color: Colors.white),
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
                      onPressed: addCollaborator,
                      child: Text(
                        'Aggiungi collaboratore',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: TextButton(
                    //     child: Text('Importa da Excel'),
                    //     onPressed: () {
                    //       pickAndExtractExcelFile();
                    //     },
                    //   ),
                    // ),
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
