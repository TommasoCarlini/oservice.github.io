import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/exercise.dart';
import 'package:oservice/enums/exerciseType.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

class AddExerciseScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const AddExerciseScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final FirebaseHelper firebaseHelper = FirebaseHelper.initialize();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final List<TextEditingController> materialControllers = [];

  ExerciseType? selectedType;

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchIsEditMode();
  }

  Future<void> _fetchSavedExercise() async {
    try {
      String savedExerciseId = await FirebaseHelper.getIdSavedExercise();
      Exercise savedExercise =
          await FirebaseHelper.getExerciseById(savedExerciseId);
      populateFields(savedExercise);
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero dell\'esercizio salvato: $e'));
    }
  }

  Future<void> _fetchIsEditMode() async {
    bool isEditMode = await FirebaseHelper.getIsEditExerciseMode();
    setState(() {
      if (isEditMode) {
        _fetchSavedExercise();
      }
      this.isEditMode = isEditMode;
    });
  }

  void populateFields(Exercise savedExercise) {
    setState(() {
      titleController.text = savedExercise.title;
      descriptionController.text = savedExercise.description;
      typeController.text = savedExercise.type.type;
      for (var material in savedExercise.material) {
        materialControllers.add(TextEditingController(text: material));
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    for (var controller in materialControllers) {
      controller.dispose();
    }
    super.dispose();
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

  void addMaterialField() {
    setState(() {
      materialControllers.add(TextEditingController());
    });
  }

  void showSuccessSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$title aggiunto agli esercizi!',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showSuccessUpdateSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$title modificat!',
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
          message: 'Errore durante l\'aggiunta dell\'eserciio: $exception',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  Future<void> addExercise() async {
    final String title = titleController.text;
    final String description = descriptionController.text;
    final ExerciseType type = ExerciseType.fromString(typeController.text);
    final List<String> materials =
        materialControllers.map((e) => e.text).toList();

    Exercise exercise = Exercise(
      title: title,
      description: description,
      type: type,
      material: materials,
    );

    Result<String> result = await firebaseHelper.addExercise(exercise);

    if (result is Success) {
      showSuccessSnackbar(title);
      changeScreen();
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  Future<void> updateExercise() async {
    final String title = titleController.text;
    final String description = descriptionController.text;
    final ExerciseType type = ExerciseType.fromString(typeController.text);
    final List<String> materials =
        materialControllers.map((e) => e.text).toList();

    Exercise exercise = Exercise(
      title: title,
      description: description,
      type: type,
      material: materials,
    );

    String exerciseId = await FirebaseHelper.getIdSavedExercise();
    Result<String> result = await firebaseHelper.updateExercise(exercise..id = exerciseId);

    if (result is Success) {
      showSuccessUpdateSnackbar(title);
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
                await FirebaseHelper.setIsExerciseSaved(false);
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Nuovo esercizio',
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
                  Expanded(
                    child: TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Titolo',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        border: UnderlineInputBorder(),
                      ),
                      items: ExerciseType.exercises()
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          typeController.text = value ?? '';
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Description Field
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  border: UnderlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),

              // Material Fields
              Text(
                'Materiale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...materialControllers.map((controller) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Materiale',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                materialControllers.remove(controller);
                              });
                            },
                            icon: Icon(Icons.delete_forever_rounded,
                                color: Colors.red.shade700)),
                      ],
                    ),
                  )),
              TextButton(
                onPressed: () {
                  addMaterialField();
                },
                child: Text(
                  'Aggiungi materiale',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
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
                      onPressed: () {
                        isEditMode ? updateExercise() : addExercise();
                      },
                      child: Text(
                        isEditMode
                            ? 'Modifica esercizio'
                            : 'Aggiungi esercizio',
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
