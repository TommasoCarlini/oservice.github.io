import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/collaboratorExtended.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

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

  FirebaseHelper firebaseHelper = FirebaseHelper.initialize();

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchIsEditMode();
  }

  Future<void> _fetchSavedCollaborator() async {
    try {
      String savedCollaboratorId = await FirebaseHelper.getIdSavedCollaborator();
      Collaborator savedCollaborator = await FirebaseHelper.getCollaboratorById(savedCollaboratorId);
      populateFields(savedCollaborator);

    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero del collaboratore: $e'));
    }
  }

  Future<void> _fetchIsEditMode() async {
    bool isEditMode = await FirebaseHelper.getIsEditCollaboratorMode();
    setState(() {
      if (isEditMode) {
        _fetchSavedCollaborator();
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
    });
  }

  void changeScreen() {
    if (Menu.fromIndex(widget.menu.index) == Menu.COLLABORATORI) {
      widget.changeTab(Menu.COLLABORATORI.index);
    }
    else if (Menu.fromIndex(widget.menu.index) == Menu.HOME) {
      widget.changeTab(Menu.AGGIUNGI_LEZIONE.index);
    }
    else {
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

  Future<void> addCollaborator() async {
    final String name = nameController.text;
    final String mail = mailController.text;
    final String phone = phoneController.text;
    final String nickname = nicknameController.text.isEmpty ? name : nicknameController.text;

    CollaboratorExtended collaborator = CollaboratorExtended(
      name: name,
      mail: mail.toLowerCase(),
      phone: phone,
      nickname: nickname,
      englishSpeaker: englishSpeakerController,
      payments: [],
      availabilities: [],
    )..nickname = nickname
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
                        labelText: 'Nome da visualizzare (se vuoto, verrà usato il nome)',
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
                  Text("Può fare lezione in inglese?", style: TextStyle(fontSize: 16),),
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
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
