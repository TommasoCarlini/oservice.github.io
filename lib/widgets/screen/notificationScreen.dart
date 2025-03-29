import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/utils/responseHandler.dart';

class NotificationScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const NotificationScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // TextEditingController payrateController = TextEditingController();
  TextEditingController visualizedDaysController = TextEditingController();
  TextEditingController archiveDaysController = TextEditingController();
  bool newEventNotification = false;
  bool updateEventNotification = false;
  bool deleteEventNotification = false;
  List<int> eventReminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() {
      isLoading = true;
    });
    String payrate = await FirebaseHelper.getDefaultPayrate();
    int visualizedDays =
        await FirebaseHelper.getNumberOfDaysBeforeToBeVisualized();
    int archiveDays =
        await FirebaseHelper.getNumberOfDaysBeforeToBeVisualizedInArchive();
    bool newEventNotificationDb =
        await FirebaseHelper.getNewEventNotification();
    bool updateEventNotificationDb =
        await FirebaseHelper.getUpdateEventNotification();
    bool deleteEventNotificationDb =
        await FirebaseHelper.getDeletedEventNotification();
    calendar.EventReminders eventRemindersDb =
        await FirebaseHelper.getEventReminders();
    setState(() {
      // payrateController.text = payrate;
      visualizedDaysController.text = visualizedDays.toString();
      archiveDaysController.text = archiveDays.toString();
      newEventNotification = newEventNotificationDb;
      updateEventNotification = updateEventNotificationDb;
      deleteEventNotification = deleteEventNotificationDb;
      if (eventRemindersDb.overrides == null) {
        eventReminders = [];
      } else {
        for (calendar.EventReminder reminder in eventRemindersDb.overrides!) {
          eventReminders.add(reminder.minutes! ~/ 60);
        }
      }
      isLoading = false; // Imposta isLoading a false dopo il caricamento
    });
  }

  @override
  void dispose() {
    // payrateController.dispose();
    visualizedDaysController.dispose();
    archiveDaysController.dispose();
    super.dispose();
  }

  // Widget per mostrare un titolo e una descrizione
  Widget _settingHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColorLight,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Theme.of(context).primaryColorLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Funzione per aggiungere un nuovo reminder
  Future<void> _addEventReminder() async {
    int? newReminder = await showDialog<int>(
      context: context,
      builder: (context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text("Aggiungi promemoria"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Quante ore prima?"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annulla"),
            ),
            TextButton(
              onPressed: () {
                int? val = int.tryParse(_controller.text);
                Navigator.of(context).pop(val);
              },
              child: Text("Aggiungi"),
            ),
          ],
        );
      },
    );
    if (newReminder != null) {
      setState(() {
        eventReminders.add(newReminder);
      });
    }
  }

  // Widget per mostrare la lista dei promemoria con possibilità di eliminare
  Widget _buildEventReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: eventReminders.map((reminder) {
        return Row(
          children: [
            Text(
              reminder == 1
                  ? "Un'ora prima dell'evento"
                  : "${reminder.toString()} ore prima dell'evento",
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  eventReminders.remove(reminder);
                });
              },
              tooltip: "Elimina promemoria",
            ),
          ],
        );
      }).toList(),
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

  Future<int> updateSettings() async {
    // Result<String> res1 = await FirebaseHelper.setDefaultPayrate(payrateController.text);
    Result<String> res2 =
        await FirebaseHelper.setNumberOfDaysBeforeToBeVisualized(
            int.parse(visualizedDaysController.text));
    Result<String> res3 =
        await FirebaseHelper.setNumberOfDaysBeforeToBeVisualizedInArchive(
            int.parse(archiveDaysController.text));
    Result<String> res4 =
        await FirebaseHelper.setNewEventNotification(newEventNotification);
    Result<String> res6 = await FirebaseHelper.setUpdateEventNotification(
        updateEventNotification);
    Result<String> res7 = await FirebaseHelper.setDeletedEventNotification(
        deleteEventNotification);
    Result<String> res5 =
        await FirebaseHelper.setEventReminders(eventReminders);
    if (res2 is Error ||
        res3 is Error ||
        res4 is Error ||
        res5 is Error ||
        res6 is Error ||
        res7 is Error) {
      showErrorSnackbar(
          Exception("Errore durante il salvataggio delle impostazioni"));
      return 1;
    }
    return 0;
  }

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Fatto!',
          message: 'Impostazioni salvate con successo',
          contentType: ContentType.success,
        ),
      ),
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
        padding: const EdgeInsets.all(42.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Impostazioni',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Sezione per "payrate"
              // Row(
              //   children: [
              //     _settingHeader(
              //         "Payrate", "Imposta il valore della paga (in €/h)"),
              //     SizedBox(width: 20),
              //     SizedBox(
              //       width: 55,
              //       child: TextFormField(
              //         style: TextStyle(
              //           color: Theme.of(context).primaryColorLight,
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //         ),
              //         controller: payrateController,
              //         keyboardType: TextInputType.number,
              //         decoration: InputDecoration(
              //           suffix: Text(
              //             "€/h",
              //             style: TextStyle(
              //               color: Theme.of(context).primaryColorLight,
              //               fontSize: 16,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           border: UnderlineInputBorder(),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 20),
              // Sezione per "numberOfDaysBeforeToBeVisualized"
              Row(
                children: [
                  _settingHeader("Giorni per visualizzazione",
                      "Imposta il numero di giorni dopo il quale non visualizzi più l'evento (visualizzazione classica e in archvio)"),
                  SizedBox(width: 40),
                  SizedBox(
                    width: 190,
                    child: TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: visualizedDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefix: Text(
                          "Nella home:  ",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        suffix: Text(
                          " giorni",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                  SizedBox(
                    width: 190,
                    child: TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: archiveDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefix: Text(
                          "In archivio:  ",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        suffix: Text(
                          " giorni",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  _settingHeader("Notifica eventi",
                      "Attiva o disattiva le notifiche per la creazione, la modifica e l'eliminazione di un evento"),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Switch(
                    value: newEventNotification,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        newEventNotification = value;
                      });
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    newEventNotification
                        ? "Notifica nuovo\nevento: ATTIVA"
                        : "Notifica nuovo\nevento: NON ATTIVA",
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
                    value: updateEventNotification,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        updateEventNotification = value;
                      });
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    updateEventNotification
                        ? "Notifica modifica\nevento: ATTIVA"
                        : "Notifica modifica\nevento: NON ATTIVA",
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
                    value: deleteEventNotification,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        deleteEventNotification = value;
                      });
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    deleteEventNotification
                        ? "Notifica eliminazione\nevento: ATTIVA"
                        : "Notifica eliminazione\nevento: NON ATTIVA",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              // Sezione per "eventReminders"
              _settingHeader("Promemoria evento",
                  "Aggiungi o elimina i promemoria evento. Non modificabili direttamente."),
              SizedBox(height: 8),
              _buildEventReminders(),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addEventReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  "Aggiungi promemoria",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Pulsante finale "Fatto!"
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
                        int res = await updateSettings();
                        if (res == 0) {
                          showSuccessSnackbar();
                          widget.changeTab(Menu.IMPOSTAZIONI.index);
                          Menu.screenRouting(Menu.IMPOSTAZIONI.index,
                              widget.changeTab, widget.menu);
                        }
                      },
                      child: Text(
                        'Salva modifiche',
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
