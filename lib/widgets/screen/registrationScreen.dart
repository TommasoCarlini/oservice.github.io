import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/payment.dart';
import 'package:oservice/enums/menu.dart';

class RegistrationScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const RegistrationScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late FirebaseHelper firebaseHelper;
  late Lesson lesson;
  bool isLoading = true;

  final TextEditingController payrateController = TextEditingController();
  bool applyDefaultPayrate = false;

  // Lista di controller per il campo paga per ogni collaboratore
  List<TextEditingController> collaboratorControllers = [];

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadLesson();
    _loadPayrateDefault();
  }

  Future<void> _loadLesson() async {
    try {
      String lessonId = await FirebaseHelper.getIdRegisteredLesson();
      lesson = await FirebaseHelper.getLessonById(lessonId);
      collaboratorControllers = lesson.collaborators
          .map((_) => TextEditingController(
              text: payrateController.text.isNotEmpty
                  ? payrateController.text
                  : "0"))
          .toList();
    } catch (e) {
      print("Errore durante il caricamento della lezione: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPayrateDefault() async {
    String payrateDefault = "0";
    try {
      payrateDefault = await FirebaseHelper.getDefaultPayrate();
    } catch (e) {
      print("Errore durante il caricamento della paga di default: $e");
    } finally {
      setState(() {
        payrateController.text = payrateDefault;
      });
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
                widget.changeTab(Menu.LEZIONI_NON_CONVALIDATE.index);
                Menu.screenRouting(Menu.LEZIONI_NON_CONVALIDATE.index, widget.changeTab, widget.menu);
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
  void dispose() {
    payrateController.dispose();
    for (var controller in collaboratorControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    String titleText() {
      return "${lesson.title} - ${lesson.entity.name}";
    }

    String participantsText() {
      return "con ${lesson.numberOfParticipants} partecipanti";
    }

    String collaboratorsText() {
      return "e ${lesson.collaborators.length} collaboratori";
    }

    String aroundMinutes(int minutes) {
      int roundedMinutes = ((minutes / 15).round() * 15) % 60;
      return roundedMinutes < 10
          ? '0$roundedMinutes'
          : roundedMinutes.toString();
    }

    double evaluateDuration() {
      return lesson.endDate.difference(lesson.startDate).inMinutes.toDouble();
    }

    String durationText() {
      if (lesson.startDate.day != lesson.endDate.day) {
        return lesson.endDate.day - lesson.startDate.day == 0
            ? "1 giorno"
            : "${lesson.endDate.day - lesson.startDate.day + 1} giorni";
      }
      double total = evaluateDuration();
      int hours = (total / 60).floor();
      int minutes = (total % 60).floor();
      return hours > 0
          ? minutes > 0
              ? "$hours ore e $minutes minuti"
              : "$hours ore"
          : "$minutes minuti";
    }

    String timingText() {
      if (lesson.startDate.day != lesson.endDate.day) {
        return "La lezione è durata ${durationText()}, dal ${lesson.startDate.day}/${lesson.startDate.month} al ${lesson.endDate.day}/${lesson.endDate.month}";
      }
      return "La lezione è durata ${durationText()}, dalle ${lesson.startDate.hour}:${aroundMinutes(lesson.startDate.minute)} alle ${lesson.endDate.hour}:${aroundMinutes(lesson.endDate.minute)} del ${lesson.startDate.day}/${lesson.startDate.month}";
    }

    String locationText() {
      return "Svolta a ${lesson.location.title}";
    }

    double evaluatePayrateTotal() {
      if (payrateController.text.isEmpty) {
        return 0;
      }
      if (evaluateDuration() > 60 * 24) {
        return double.parse(payrateController.text) * evaluateDuration() / (60 * 24);
      }
      return double.parse(payrateController.text) * evaluateDuration() / 60;
    }

    double evaluatePayrateCollaborator() {
      return evaluatePayrateTotal() / lesson.collaborators.length;
    }

    void applyDefaultPayrateToEveryone() {
      for (var controller in collaboratorControllers) {
        controller.text = evaluatePayrateTotal.toString();
      }
    }

    String getCollaboratorName(Collaborator collaborator) {
      if (lesson.responsible != null && lesson.responsible!.name.isNotEmpty) {
        if (collaborator.name == lesson.responsible!.name) {
          if (collaborator.nickname != null) {
            return " - ${collaborator.nickname} (Resp.)";
          }
          return " - ${collaborator.name} (Resp.)";
        }
      }
      if (collaborator.nickname != null) {
        return " - ${collaborator.nickname}";
      }
      return " - ${collaborator.name}";
    }

    double totalPayrate() {
      double total = 0;
      for (var controller in collaboratorControllers) {
        if (controller.text.isEmpty) {
          continue;
        }
        total += double.parse(controller.text);
      }
      return total;
    }

    void showSuccessSnackbar() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Registrata!',
            message: 'Hai registrato la lezione!',
            contentType: ContentType.success,
          ),
        ),
      );
    }

    void showErrorSnackbar() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Azione bloccata!',
            message: 'Alcuni collaboratori non hanno una paga impostata',
            contentType: ContentType.failure,
          ),
        ),
      );
    }

    Future<void> registerLesson() async {
      setState(() {
        isLoading = true;
      });
      if (collaboratorControllers.any(
        (element) {
          return element.text.isEmpty;
        },
      )) {
        showErrorSnackbar();
      } else {
        int length = collaboratorControllers.length;
        for (int i = 0; i < length; i++) {
          String name = lesson.collaborators[i].name;
          int amount = int.parse(collaboratorControllers[i].text);
          Payment payment = Payment(
              name: name, amount: amount, date: lesson.endDate, paid: false, lessonId: lesson.id);
          lesson.addPayment(name, amount);
          await FirebaseHelper.addPayment(payment.toMap());
        }
        FirebaseHelper firebaseHelper = FirebaseHelper.initialize();
        await firebaseHelper.updateLesson(lesson);
        setState(() {
          isLoading = false;
        });
        showSuccessSnackbar();
        widget.changeTab(Menu.LEZIONI_NON_CONVALIDATE.index);
      }
      setState(() {
        isLoading = false;
      });
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
            Text(
              "Registra la lezione",
              style: Theme.of(context).primaryTextTheme.titleMedium,
            ),
            SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${titleText()}, ${participantsText()} ${collaboratorsText()}.\n${timingText()}.\n${locationText()}",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Supponendo una paga di ",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: TextFormField(
                    controller: payrateController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (applyDefaultPayrate) {
                          applyDefaultPayrateToEveryone();
                        }
                      });
                    },
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "€/h, il totale da pagare è di ${evaluatePayrateTotal()}€ (${evaluatePayrateCollaborator().toStringAsFixed(2)}€ a collaboratore).",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                Switch(
                  onChanged: (bool value) {
                    setState(() {
                      applyDefaultPayrate = value;
                    });
                    if (applyDefaultPayrate) {
                      applyDefaultPayrateToEveryone();
                    }
                  },
                  value: applyDefaultPayrate,
                  activeColor: Colors.orange,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Applica questa paga a tutti",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Sezione per la lista dei collaboratori e il relativo campo di paga
            if (lesson.collaborators.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Paga per collaboratore: (totale da pagare di ${totalPayrate()}€)",
                    style: Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                  ...List.generate(lesson.collaborators.length, (index) {
                    final collaborator = lesson.collaborators[index];
                    return Row(
                      children: [
                        Text(
                          getCollaboratorName(collaborator),
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: collaboratorControllers[index],
                            decoration: InputDecoration(
                              suffix: Text(
                                "€",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              border: UnderlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            SizedBox(height: 30),
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
                      registerLesson();
                    },
                    child: Text(
                      "Registra lezione",
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
    );
  }
}
