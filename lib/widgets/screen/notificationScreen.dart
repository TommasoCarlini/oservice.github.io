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
    calendar.EventReminders eventRemindersDb =
        await FirebaseHelper.getEventReminders();
    setState(() {
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
    super.dispose();
  }

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
    Result<String> result =
        await FirebaseHelper.setEventReminders(eventReminders);
    if (result is Error) {
      showErrorSnackbar(
          Exception("Errore durante il salvataggio delle notifiche"));
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
          message: 'Notifiche salvate con successo',
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
                  'Notifiche',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              _settingHeader("Promemoria evento",
                  "Aggiungi o elimina i promemoria evento. I promemoria non sono modificabili."),
              SizedBox(height: 20),
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
