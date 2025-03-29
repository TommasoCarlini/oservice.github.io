import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as CalendarApi;
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/exercise.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/location.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/google/calendarClient.dart';
import 'package:oservice/utils/responseHandler.dart';
import 'package:oservice/widgets/dropdown/collaboratorsDropdown.dart';
import 'package:oservice/widgets/dropdown/entitiesDropdown.dart';
import 'package:oservice/widgets/dropdown/exercisesDropdown.dart';
import 'package:oservice/widgets/dropdown/locationsDropdown.dart';
import 'package:oservice/widgets/utils/dateRowWidget.dart';
import 'package:oservice/widgets/utils/englishWarningicon.dart';
import 'package:time_range_picker/time_range_picker.dart';

class AddLessonScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const AddLessonScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _AddLessonScreenState createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final FirebaseHelper firebaseHelper = FirebaseHelper.initialize();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController entityController = TextEditingController();
  final TextEditingController exerciseController = TextEditingController();
  final TextEditingController collaboratorsController = TextEditingController();
  final TextEditingController collaboratorsNeededController =
  TextEditingController();
  final TextEditingController responsibleCollaborator = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController participantsController = TextEditingController();
  bool englishSpeakerController = false;
  bool schoolCampController = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(hours: 4));

  Location? selectedLocation;
  List<Location> allLocations = [];
  List<Location> filteredLocations = [];

  Entity? selectedEntity;
  List<Entity> allEntities = [];
  List<Entity> filteredEntities = [];

  List<Exercise> chosenExercises = [];
  List<Exercise> allExercises = [];

  List<Collaborator> chosenCollaborators = [];
  List<Collaborator> allCollaborators = [];
  Collaborator? selectedResponsible;

  bool showCollaborators = false;

  bool isLoading = false;

  bool isEditMode = false;
  String confirmButtonText = 'Aggiungi lezione';

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchEntities();
    _fetchExercises();
    _fetchCollaborators();
    _fetchIsEditMode();
  }

  void populateFields(Lesson savedLesson) {
    setState(() {
      titleController.text = savedLesson.title;
      notesController.text = savedLesson.description;
      entityController.text = savedLesson.entity.name;
      selectedEntity = savedLesson.entity;
      englishSpeakerController = savedLesson.isInEnglish;
      locationController.text = savedLesson.location.title;
      if (savedLesson.responsible != null) {
        selectedResponsible = savedLesson.responsible;
        responsibleCollaborator.text = savedLesson.responsible!.name;
      }
      selectedLocation = savedLesson.location;
      startDate = savedLesson.startDate;
      endDate = savedLesson.endDate;
      participantsController.text = savedLesson.numberOfParticipants.toString();
      collaboratorsNeededController.text =
          savedLesson.collaboratorsNeeded.toString();
      schoolCampController = startDate.day != endDate.day;
      chosenCollaborators = savedLesson.collaborators;
      chosenExercises = savedLesson.exercises;
    });
  }

  Future<void> _fetchLocations() async {
    try {
      List<Location> locations = await FirebaseHelper.getAllLocations();
      locations.sort((a, b) => a.title.compareTo(b.title));
      setState(() {
        filteredLocations = locations;
        allLocations = locations;
      });
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero delle locations: $e'));
    }
  }

  Future<void> _fetchEntities() async {
    try {
      List<Entity> entities = await FirebaseHelper.getAllEntities();
      entities.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        filteredEntities = entities;
        allEntities = entities;
      });
    } catch (e) {
      showErrorSnackbar(Exception('Errore durante il recupero degli enti: $e'));
    }
  }

  Future<void> _fetchExercises() async {
    try {
      List<Exercise> exercises = await FirebaseHelper.getAllExercises();
      exercises.sort((a, b) => a.title.compareTo(b.title));
      setState(() {
        allExercises = exercises;
      });
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero degli esercizi: $e'));
    }
  }

  Future<void> _fetchCollaborators() async {
    try {
      List<Collaborator> collaborators =
      await FirebaseHelper.getAllCollaborators();
      collaborators.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        allCollaborators = collaborators;
      });
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero dei collaboratori: $e'));
    }
  }

  Future<void> _fetchEditingLesson() async {
    try {
      String savedLessonId = await FirebaseHelper.getIdSavedLesson();
      Lesson savedLesson = await FirebaseHelper.getLessonById(savedLessonId);
      populateFields(savedLesson);
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero della lezione salvata: $e'));
    }
  }

  Future<void> _fetchSavedLesson() async {
    try {
      bool isSavedLesson = await FirebaseHelper.getIsLessonSaved();
      if (isSavedLesson) {
        Lesson savedLesson = await FirebaseHelper.getSavedLesson();
        populateFields(savedLesson);
      }
    } catch (e) {
      showErrorSnackbar(
          Exception('Errore durante il recupero della lezione salvata: $e'));
    }
  }

  Future<void> _fetchIsEditMode() async {
    bool isEditMode = await FirebaseHelper.getIsEditLessonMode();
    bool isSaved = await FirebaseHelper.getIsLessonSaved();
    setState(() {
      if (isEditMode) {
        _fetchEditingLesson();
      } else if (isSaved) {
        _fetchSavedLesson();
      }
      this.isEditMode = isEditMode;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void changeScreen() {
    widget.changeTab(widget.menu.previousIndex);
  }

  Future<void> addLesson() async {
    Lesson newLesson = Lesson(
      title: titleController.text,
      description: notesController.text,
      startDate: startDate,
      endDate: endDate,
      collaboratorsNeeded: int.parse(collaboratorsNeededController.text),
      isInEnglish: englishSpeakerController,
      notes: notesController.text,
      numberOfParticipants: int.parse(participantsController.text),
      salary: 0.0,
    )
      ..collaborators = chosenCollaborators
      ..exercises = chosenExercises
      ..location = selectedLocation!
      ..entity = selectedEntity!
      ..responsible = selectedResponsible;

    setState(() {
      isLoading = true;
    });
    CalendarApi.Event event = await newLesson.mapToEvent();
    Result<String> calendarApiResult =
    await CalendarClient.addEvent(event, newLesson.entity.calendarId);
    Result<String> result = await firebaseHelper.addLesson(newLesson
      ..eventId = (calendarApiResult as Success).data
      ..isInCalendar = true);
    setState(() {
      isLoading = false;
    });

    if (result is Success) {
      newLesson.id = (result as Success).data;
      await FirebaseHelper.updateCollaboratorsLesson(
          chosenCollaborators, newLesson.id);
      showSuccessSnackbar(titleController.text);
      widget.changeTab(Menu.HOME.index);
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  Future<void> updateLesson(bool sendNotification) async {
    Lesson newLesson = Lesson(
      title: titleController.text,
      description: notesController.text,
      startDate: startDate,
      endDate: endDate,
      collaboratorsNeeded: int.parse(collaboratorsNeededController.text),
      isInEnglish: englishSpeakerController,
      notes: notesController.text,
      numberOfParticipants: int.parse(participantsController.text),
      salary: 0.0,
    )
      ..id = await FirebaseHelper.getIdSavedLesson()
      ..collaborators = chosenCollaborators
      ..exercises = chosenExercises
      ..location = selectedLocation!
      ..entity = selectedEntity!
      ..responsible = selectedResponsible;

    setState(() {
      isLoading = true;
    });

    Lesson savedLesson = await FirebaseHelper.getLessonById(
        await FirebaseHelper.getIdSavedLesson());
    CalendarApi.Event event = await newLesson.mapToEvent()
      ..id = savedLesson.eventId;

    Result<String> calendarApiResult;
    if (newLesson.entity.id != savedLesson.entity.id) {
      calendarApiResult = await CalendarClient.deleteEvent(
          savedLesson.entity.calendarId, savedLesson.eventId);
      calendarApiResult =
      await CalendarClient.addEvent(event, newLesson.entity.calendarId);
    } else {
      calendarApiResult = await CalendarClient.updateEvent(
          event, newLesson.entity.calendarId, event.id!, sendNotification);
    }
    Result<String> result = await firebaseHelper.updateLesson(newLesson
      ..eventId = (calendarApiResult as Success).data
      ..isInCalendar = true);
    setState(() {
      isLoading = false;
    });

    if (result is Success) {
      newLesson.id = (result as Success).data;
      await FirebaseHelper.updateCollaboratorsLesson(
          chosenCollaborators, newLesson.id);
      showSuccessSnackbar(titleController.text);
      widget.changeTab(Menu.HOME.index);
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  Future<void> saveLesson() async {
    await FirebaseHelper.setIsLessonSaved(true);
    await FirebaseHelper.setIdSavedLesson("");
    Lesson newLesson = Lesson(
      title: titleController.text,
      description: notesController.text,
      startDate: startDate,
      endDate: endDate,
      collaboratorsNeeded: int.parse(collaboratorsNeededController.text),
      isInEnglish: englishSpeakerController,
      notes: notesController.text,
      numberOfParticipants: int.parse(participantsController.text),
      salary: 0.0,
    )
      ..id = ""
      ..collaborators = chosenCollaborators
      ..exercises = chosenExercises
      ..location = selectedLocation!
      ..entity = selectedEntity!
      ..responsible = selectedResponsible;

    setState(() {
      isLoading = true;
    });
    Result<String> result = await firebaseHelper.saveLesson(newLesson
      ..eventId = ""
      ..isInCalendar = false);
    setState(() {
      isLoading = false;
    });

    if (result is Success) {
      newLesson.id = (result as Success).data;
      showSuccessSnackbar(titleController.text);
      widget.changeTab(Menu.HOME.index);
    } else {
      showErrorSnackbar((result as Error).exception);
    }
  }

  void showSuccessAddCollaboratorSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Aggiunto!',
          message: 'Hai aggiunto $name ai collaboratori!',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showSuccessRemoveCollaboratorSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Rimosso!',
          message: 'Hai rimosso $name dai collaboratori!',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showSuccessSavedLessonSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: 'Lezione salvata con successo!',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showSuccessSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: '$title aggiunta!',
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
            isEditMode
                ? SizedBox()
                : TextButton(
              onPressed: () async {
                await saveLesson();
                Navigator.of(context).pop();
                widget.changeTab(Menu.HOME.index);
              },
              child: Text(
                'Salva ed esci',
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseHelper.setIsLessonSaved(false);
                await FirebaseHelper.setIdSavedLesson("");
                Navigator.of(context).pop();
                widget.changeTab(Menu.HOME.index);
              },
              child: Text(
                'Esci senza salvare',
                style: TextStyle(color: Colors.red),
              ),
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

    bool isCollaboratorInList(Collaborator collaborator) {
      return chosenCollaborators.any(
            (element) => element.name == collaborator.name,
      );
    }

    bool isExerciseInList(Exercise exercise) {
      return chosenExercises.any(
            (element) => element.title == exercise.title,
      );
    }

    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Aggiungi una nuova lezione",
                style: Theme.of(context).primaryTextTheme.titleMedium,
              ),
              SizedBox(height: 20),

              // TITLE, ENTITY, LOCATION
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
                  SizedBox(width: 40),
                  IconButton(
                      onPressed: () {
                        widget.changeTab(Menu.AGGIUNGI_ENTE.index);
                      },
                      icon: Icon(Icons.add_home_work_rounded)),
                  EntityDropdown(
                      controller: entityController,
                      filteredEntities: filteredEntities,
                      onSelected: (Entity? entity) {
                        setState(() {
                          selectedEntity = entity;
                        });
                      }),
                  SizedBox(width: 40),
                  IconButton(
                      onPressed: () {
                        widget.changeTab(Menu.AGGIUNGI_LOCATION.index);
                      },
                      icon: Icon(Icons.add_location_alt_rounded)),
                  LocationDropdown(
                    controller: locationController,
                    filteredLocations: filteredLocations,
                    onSelected: (Location? location) {
                      setState(() {
                        selectedLocation = location;
                      });
                    },
                  ),
                  SizedBox(width: 20),
                ],
              ),
              SizedBox(height: 20),

              // DATES
              Row(
                children: [
                  Text('Numero di partecipanti: ',
                      style: Theme.of(context).primaryTextTheme.labelMedium),
                  SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: participantsController,
                      style: Theme.of(context).primaryTextTheme.labelMedium,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (String value) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 50),
                  SizedBox(
                    width: 250,
                    child: CheckboxListTile(
                      title: Text('Campo scuola',
                          style:
                          Theme.of(context).primaryTextTheme.labelMedium),
                      value: schoolCampController,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      onChanged: (bool? value) {
                        setState(() {
                          schoolCampController = value!;
                          if (schoolCampController) {
                            startDate = DateTime(startDate.year,
                                startDate.month, startDate.day, 10, 00);
                            endDate =
                                startDate.add(Duration(days: 2, hours: 8));
                          } else {
                            endDate = startDate.add(Duration(hours: 4));
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  DateRowWidget(
                    isSchoolCamp: schoolCampController,
                    startDate: startDate,
                    endDate: endDate,
                    onStartDateChanged: (DateTime date) {
                      setState(() {
                        startDate = date
                            .add(Duration(hours: startDate.hour, minutes: startDate.minute));
                        if (schoolCampController) {
                          startDate = DateTime(startDate.year, startDate.month,
                              startDate.day, 10, 00);
                          endDate = date.add(Duration(days: 2, hours: 8));
                        } else {
                          endDate = date.add(Duration(
                              hours: endDate.hour, minutes: endDate.minute));
                        }
                      });
                    },
                    onEndDateChanged: (DateTime date) {
                      setState(() {
                        endDate = date;
                        if (schoolCampController) {
                          endDate = date.add(Duration(hours: 18));
                        }
                      });
                    },
                    onTimeChanged: (TimeRange pickedTime) {
                      setState(() {
                        startDate = DateTime(
                            startDate.year,
                            startDate.month,
                            startDate.day,
                            pickedTime.startTime.hour,
                            pickedTime.startTime.minute);
                        endDate = DateTime(
                            endDate.year,
                            endDate.month,
                            endDate.day,
                            pickedTime.endTime.hour,
                            pickedTime.endTime.minute);
                      });
                    },
                  ),
                  SizedBox(width: 20),
                ],
              ),

              // COLLABORATORS
              Row(
                children: [
                  Text('Collaboratori necessari: ',
                      style: Theme.of(context).primaryTextTheme.labelMedium),
                  SizedBox(
                    width: 25,
                    child: TextFormField(
                      controller: collaboratorsNeededController,
                      style: Theme.of(context).primaryTextTheme.labelMedium,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (String value) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 69),
                  SizedBox(
                    width: 300,
                    child: CheckboxListTile(
                      title: Text('Devono parlare inglese',
                          style:
                          Theme.of(context).primaryTextTheme.labelMedium),
                      value: englishSpeakerController,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      onChanged: (bool? value) {
                        setState(() {
                          englishSpeakerController = value!;
                        });
                      },
                    ),
                  ),
                  EnglishWarningIcon(
                    englishLesson: englishSpeakerController,
                    chosenCollaborators: chosenCollaborators,
                  ),
                ],
              ),
              Row(
                children: [
                  Tooltip(
                    verticalOffset: -40,
                    message: chosenCollaborators.map((collaborator) {
                      return collaborator.name;
                    }).join(', '),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: Theme.of(context).primaryTextTheme.labelSmall,
                    child: Text(
                        'Collaboratori: ${chosenCollaborators.length} su ${collaboratorsNeededController.text.isEmpty ? 0 : collaboratorsNeededController.text}',
                        style: Theme.of(context).primaryTextTheme.labelMedium),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          showCollaborators = !showCollaborators;
                        });
                      },
                      icon: showCollaborators
                          ? Icon(
                        Icons.visibility_rounded,
                        size: 18,
                        color: Theme.of(context).primaryColorLight,
                      )
                          : Icon(
                        Icons.visibility_off_rounded,
                        size: 18,
                        color: Theme.of(context).primaryColorLight,
                      )),
                  SizedBox(width: 10),
                  Text(
                      showCollaborators
                          ? chosenCollaborators.map((collaborator) {
                        return collaborator.name;
                      }).join(', ')
                          : '',
                      style: Theme.of(context).primaryTextTheme.labelMedium),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        widget.changeTab(Menu.AGGIUNGI_COLLABORATORE.index);
                      },
                      icon: Icon(Icons.person_add_alt_1_rounded)),
                  CollaboratorDropdown(
                    controller: collaboratorsController,
                    filteredCollaborators: allCollaborators,
                    chosenCollaborators: chosenCollaborators,
                    englishLesson: englishSpeakerController,
                    onSelected: (Collaborator? collaborator) {
                      setState(() {
                        if (collaborator != null) {
                          if (isCollaboratorInList(collaborator)) {
                            chosenCollaborators.removeWhere(
                                    (element) => element.name == collaborator.name);
                            if (responsibleCollaborator.text ==
                                collaborator.name) {
                              responsibleCollaborator.clear();
                              selectedResponsible = null;
                            }
                          } else {
                            chosenCollaborators.add(collaborator);
                          }
                          collaboratorsController.clear();
                          if (isCollaboratorInList(collaborator)) {
                            showSuccessAddCollaboratorSnackbar(
                                collaborator.name);
                          } else {
                            showSuccessRemoveCollaboratorSnackbar(
                                collaborator.name);
                          }
                        }
                      });
                    },
                  ),
                  SizedBox(width: 20),
                  DropdownMenu<Collaborator>(
                    width: 400,
                    label: Text('Responsabile'),
                    inputDecorationTheme: InputDecorationTheme(
                      border: UnderlineInputBorder(),
                    ),
                    hintText: 'Seleziona il responsabile',
                    controller: responsibleCollaborator,
                    enableFilter: true,
                    dropdownMenuEntries:
                    chosenCollaborators.map((collaborator) {
                      return DropdownMenuEntry<Collaborator>(
                        value: collaborator,
                        label: collaborator.name,
                      );
                    }).toList(),
                    onSelected: (Collaborator? collaborator) {
                      if (collaborator != null) {
                        setState(() {
                          responsibleCollaborator.text = collaborator.name;
                          selectedResponsible = collaborator;
                        });
                      }
                    },
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 20),

              // EXERCISES
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      chosenExercises.isEmpty
                          ? 'Nessun esercizio selezionato'
                          : 'Esercizi:  ${chosenExercises.map((exercise) {
                        return exercise.title;
                      }).join(', ')}',
                      style: Theme.of(context).primaryTextTheme.labelMedium),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        widget.changeTab(Menu.AGGIUNGI_ESERCIZIO.index);
                      },
                      icon: Icon(Icons.add_chart_rounded)),
                  ExerciseDropdown(
                    controller: exerciseController,
                    filteredExercises: allExercises,
                    chosenExercises: chosenExercises,
                    onSelected: (Exercise? exercise) {
                      setState(() {
                        if (exercise != null) {
                          if (isExerciseInList(exercise)) {
                            chosenExercises.removeWhere(
                                    (element) => element.title == exercise.title);
                          } else {
                            chosenExercises.add(exercise);
                          }
                          exerciseController.clear();
                        }
                      });
                    },
                  ),
                  SizedBox(width: 20),
                ],
              ),

              // NOTES
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: UnderlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 20),

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
                        isEditMode ? updateLesson(false) : addLesson();
                      },
                      child: Text(
                        isEditMode ? "Salva le modifiche" : "Aggiungi lezione",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
                      ),
                    ),
                    isEditMode ?
                    SizedBox(width: 20) :
                    SizedBox(width: 0,),
                    isEditMode ?
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
                        updateLesson(true);
                      },
                      child: Text(
                        "Salva e invia notifica",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
                      ),
                    ) :
                    SizedBox(width: 0,),
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
