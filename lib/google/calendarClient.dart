import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/utils/responseHandler.dart' as ResponseHandler;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class CalendarClient {
  static final _scopes = [CalendarApi.calendarScope];

  static final String clientIdKey =
      "260302146946-0vmo4aqqht43n991b67d9l4gmbjbkkho.apps.googleusercontent.com";
  static final String apiKey = "AIzaSyAyCYlPnIvp_7xLFg3FSjS4E2tAjlDKVIw";

  // final ClientId _clientID = ClientId(
  //     clientIdKey,
  //     "");

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientIdKey,
    scopes: <String>[
      CalendarApi.calendarScope,
      CalendarApi.calendarEventsScope,
    ],
  );

  // get http => null;

  Future<AuthClient> obtainAuthenticatedClient() async {
    final ServiceAccountCredentials accountCredentials =
        ServiceAccountCredentials.fromJson({});
    AuthClient client =
        await clientViaServiceAccount(accountCredentials, _scopes);

    return client;
  }

  static Future<dynamic> readJson() async {
    final String response =
        await rootBundle.loadString('assets/service-account-private-key.json');
    return await json.decode(response);
  }

  static Future<ResponseHandler.Result<String>> createCalendar(
      Calendar calendar, String color) async {
    List<String> scopes = [CalendarApi.calendarScope];

    final String response =
        await rootBundle.loadString('service-account-private-key.json');
    final Object jsonCredentials = json.decode(response);

    final ServiceAccountCredentials accountCredentials =
        ServiceAccountCredentials.fromJson(jsonCredentials);
    AutoRefreshingAuthClient client =
        await clientViaServiceAccount(accountCredentials, scopes);

    try {
      CalendarApi calendarApi = CalendarApi(client);
      Calendar createdCalendar = await calendarApi.calendars.insert(calendar);

      String userToShareWith = "ori.servicesrl@gmail.com";
      AclRule aclRule = AclRule()
        ..scope = (AclRuleScope()
          ..type = "user"
          ..value = userToShareWith)
        ..role = "owner";

      await calendarApi.acl.insert(aclRule, createdCalendar.id!);

      // print("Aggiungo un evento di prova");
      // Event event = Event()
      //   ..summary = 'Evento di prova'
      //   ..description = 'Un evento di prova aggiunto tramite Google Calendar API'
      //   ..start = EventDateTime()
      //   ..end = EventDateTime()
      //   ..start!.dateTime = DateTime.now().add(Duration(days: 1))
      //   ..end!.dateTime = DateTime.now().add(Duration(days: 1, hours: 1))
      //   ..reminders = EventReminders()
      //   ..reminders!.useDefault = false
      //   ..reminders!.overrides = [
      //     EventReminder()
      //       ..method = "email"
      //       ..minutes = 24 * 60,
      //     EventReminder()
      //       ..method = "popup"
      //       ..minutes = 10,
      //   ];
      //
      // Event createdEvent = await calendarApi.events.insert(event, createdCalendar.id!);
      //
      // print('Evento creato con ID: ${createdEvent.id}');

      String url =
          'https://www.google.com/calendar/render?cid=${createdCalendar.id}';
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }

      CalendarListEntry calendarListEntry =
          await calendarApi.calendarList.get(createdCalendar.id!);
      calendarListEntry.backgroundColor = color;
      await calendarApi.calendarList
          .update(calendarListEntry, createdCalendar.id!, colorRgbFormat: true);

      client.close();
      return ResponseHandler.Success(data: createdCalendar.id!);
    } on Exception catch (e) {
      client.close();
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> addCalendar(
      Calendar calendar, String color) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      Calendar createdCalendar = await calendarApi.calendars.insert(calendar);
      CalendarListEntry calendarListEntry =
          await calendarApi.calendarList.get(createdCalendar.id!);
      calendarListEntry.backgroundColor = color;
      await calendarApi.calendarList
          .update(calendarListEntry, createdCalendar.id!, colorRgbFormat: true);
      return ResponseHandler.Success(data: createdCalendar.id!);
    } on Exception catch (e) {
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> updateCalendar(
      Calendar calendar, String calendarId, String color) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      Calendar updatedCalendar = await calendarApi.calendars.update(calendar, calendarId);
      CalendarListEntry calendarListEntry =
      await calendarApi.calendarList.get(updatedCalendar.id!);
      calendarListEntry.backgroundColor = color;
      await calendarApi.calendarList
          .update(calendarListEntry, updatedCalendar.id!, colorRgbFormat: true);
      return ResponseHandler.Success(data: calendarId);
    } on Exception catch (e) {
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> deleteCalendar(String calendarId) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      await calendarApi.calendars.delete(calendarId);
      return ResponseHandler.Success(data: calendarId);
    } on Exception catch (e) {
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> addEvent(Event event, String calendarId) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      bool sendNotification = await FirebaseHelper.getNewEventNotification();
      Event createdEvent = await calendarApi.events.insert(event, calendarId, sendNotifications: sendNotification);
      return ResponseHandler.Success(data: createdEvent.id!);
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'evento: $e");
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> updateEvent(Event event, String calendarId, String eventId) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      await calendarApi.events.update(event, calendarId, eventId);
      return ResponseHandler.Success(data: eventId);
    } on Exception catch (e) {
      print("Errore durante l'aggiornamento dell'evento: $e");
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> deleteEvent(String calendarId, String eventId) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      await calendarApi.events.delete(calendarId, eventId);
      return ResponseHandler.Success(data: eventId);
    } on Exception catch (e) {
      print("Errore durante l'eliminazione dell'evento: $e");
      return ResponseHandler.Error(exception: e);
    }
  }

  // static Future<void> changeCalendarColor(String name) async {
  //   List<String> scopes = [CalendarApi.calendarScope];
  //
  //   final String response = await rootBundle.loadString('service-account-private-key.json');
  //   final Object jsonCredentials = json.decode(response);
  //
  //   final ServiceAccountCredentials accountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
  //   AutoRefreshingAuthClient client = await clientViaServiceAccount(accountCredentials, scopes);
  //
  //   try {
  //     CalendarApi calendarApi = CalendarApi(client);
  //
  //     CalendarList calendarList = await calendarApi.calendarList.list();
  //     for (CalendarListEntry calendar in calendarList.items!) {
  //       if (calendar.summary == name) {
  //         print("Il colore del calendario $name è ${calendar.backgroundColor}, provo a cambiarlo con #ff0000");
  //         calendar.backgroundColor = "#ff0000";
  //         CalendarListEntry a = await calendarApi.calendarList.update(calendar, calendar.id!, colorRgbFormat: true);
  //         print("Colore cambiato con successo");
  //         getCalendarColor(name);
  //       }
  //     }
  //     client.close();
  //   } on Exception catch (e) {
  //     client.close();
  //   }
  // }

  static Future<void> changeCalendarColor(String id, String color) async {
    await _googleSignIn.signIn();
    final client = await _googleSignIn.authenticatedClient();
    final CalendarApi calendarApi = CalendarApi(client as http.Client);
    CalendarListEntry calendars = await calendarApi.calendarList.get(id);
    calendars.backgroundColor = color;
    await calendarApi.calendarList.update(calendars, id, colorRgbFormat: true);
  }

  static Future<void> getCalendarColor(String name) async {
    List<String> scopes = [CalendarApi.calendarScope];

    final String response =
        await rootBundle.loadString('service-account-private-key.json');
    final Object jsonCredentials = json.decode(response);

    final ServiceAccountCredentials accountCredentials =
        ServiceAccountCredentials.fromJson(jsonCredentials);
    AutoRefreshingAuthClient client =
        await clientViaServiceAccount(accountCredentials, scopes);

    try {
      CalendarApi calendarApi = CalendarApi(client);

      CalendarList calendarList = await calendarApi.calendarList.list();
      for (CalendarListEntry calendar in calendarList.items!) {
        if (calendar.summary == name) {
          print("Il colore del calendario $name è ${calendar.backgroundColor}");
        }
      }
      client.close();
    } on Exception catch (e) {
      client.close();
    }
  }

  static Future<ResponseHandler.Result<String>> insertEvent(
      Event event, String calendarId) async {
    List<String> scopes = [CalendarApi.calendarScope];

    final String response =
        await rootBundle.loadString('service-account-private-key.json');
    final Object jsonCredentials = json.decode(response);

    final ServiceAccountCredentials accountCredentials =
        ServiceAccountCredentials.fromJson(jsonCredentials);
    AutoRefreshingAuthClient client =
        await clientViaServiceAccount(accountCredentials, scopes);

    try {
      CalendarApi calendarApi = CalendarApi(client);
      Event createEvent = await calendarApi.events.insert(event, calendarId);

      // print("Aggiungo un evento di prova");
      // Event event = Event()
      //   ..summary = 'Evento di prova'
      //   ..description = 'Un evento di prova aggiunto tramite Google Calendar API'
      //   ..start = EventDateTime()
      //   ..end = EventDateTime()
      //   ..start!.dateTime = DateTime.now().add(Duration(days: 1))
      //   ..end!.dateTime = DateTime.now().add(Duration(days: 1, hours: 1))
      //   ..reminders = EventReminders()
      //   ..reminders!.useDefault = false
      //   ..reminders!.overrides = [
      //     EventReminder()
      //       ..method = "email"
      //       ..minutes = 24 * 60,
      //     EventReminder()
      //       ..method = "popup"
      //       ..minutes = 10,
      //   ];
      //
      // Event createdEvent = await calendarApi.events.insert(event, createdCalendar.id!);
      //
      // print('Evento creato con ID: ${createdEvent.id}');

      client.close();
      return ResponseHandler.Success(data: event.id!);
    } on Exception catch (e) {
      client.close();
      return ResponseHandler.Error(exception: e);
    }
    //
    // AuthClient authClient = await obtainAuthenticatedClient();
    //
    // print("Authenticated client obtained");
    // print(authClient.credentials.accessToken);
    // try {
    //   List<String> scopes = [CalendarApi.calendarScope];
    //
    //   AutoRefreshingAuthClient client = await clientViaServiceAccount(accountCredentials, scopes);
    //   final calendarApi = CalendarApi(client);
    //
    //   Event event = Event()
    //     ..summary = title
    //     ..start = (EventDateTime()
    //       ..dateTime = startTime
    //       ..timeZone = "GMT+05:00")
    //     ..end = (EventDateTime()
    //       ..dateTime = endTime
    //       ..timeZone = "GMT+05:00");
    //
    //   calendarApi.events.insert(event, calendarId).then((value) {
    //     if (value.status == "confirmed") {
    //       print('Event added in google calendar');
    //     } else {
    //       print("Unable to add event in google calendar");
    //     }
    //   });
    // } catch (e) {
    //   print("Error inserting event: $e");
    // }
  }

  // Future<void> listCalendars() async {
  //   var scopes = [CalendarApi.calendarScope];
  //   var client = await clientViaServiceAccount(accountCredentials, scopes);
  //
  //   try {
  //     var calendarApi = CalendarApi(client);
  //     var calendarList = await calendarApi.calendarList.list();
  //
  //     if (calendarList.items != null) {
  //       for (var calendar in calendarList.items!) {
  //         print('Calendario: ${calendar.summary}, ID: ${calendar.id}');
  //       }
  //     } else {
  //       print('Nessun calendario trovato.');
  //     }
  //   } catch (e) {
  //     print('Errore durante la visualizzazione dei calendari: $e');
  //   } finally {
  //     client.close(); // Chiudi il client
  //   }
  // }
  //
  // void prompt(String url) async {
  //   print("Please go to the following URL and grant access:");
  //   print("  => $url");
  //   print("");
  //
  //   Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  //
  // Future<void> authenticateUser() async {
  //   final clientId = clientIdKey;
  //   final redirectUri = 'http://localhost:8004/';
  //   final scope = 'https://www.googleapis.com/auth/calendar';
  //
  //   print("Authenticating user...");
  //
  //   final authUrl = Uri.parse(
  //     'https://accounts.google.com/o/oauth2/auth'
  //         '?response_type=code'
  //         '&client_id=$clientId'
  //         '&redirect_uri=$redirectUri'
  //         '&scope=$scope'
  //         '&access_type=offline',
  //   );
  //
  //   print("Auth URL: $authUrl");
  //
  //   // Apri una finestra di autenticazione (o fai un redirect)
  //   final result = await authenticateInBrowser(authUrl);
  //
  //   print("Result: $result");
  //
  //   if (result != null) {
  //     // Estrai il codice di autenticazione dalla risposta
  //     final code = Uri.parse(result).queryParameters['code'];
  //
  //     // Richiesta del token di accesso
  //     final tokenUrl = 'https://oauth2.googleapis.com/token';
  //     final response = await http.post(
  //       Uri.parse(tokenUrl),
  //       body: {
  //         'client_id': clientId,
  //         'redirect_uri': redirectUri,
  //         'grant_type': 'authorization_code',
  //         'code': code,
  //       },
  //     );
  //
  //     final accessToken = json.decode(response.body)['access_token'];
  //     print("Access Token: $accessToken");
  //
  //     // Procedi a creare un calendario o un evento usando l'access token
  //     createCalendar2(accessToken);
  //   } else {
  //     print("Errore durante l'autenticazione");
  //   }
  // }
  //
  // Future<String?> authenticateInBrowser(Uri authUrl) async {
  //   // Completer per restituire il risultato in futuro.
  //   final Completer<String?> completer = Completer();
  //
  //   try {
  //     print("Opening browser window...");
  //     // Parametri per configurare la finestra come un pop-up
  //     final popupFeatures = "width=600,height=600,menubar=no,toolbar=no,location=no,status=no";
  //     // Apri la finestra con le opzioni specificate
  //     final html.WindowBase? popupWindow = html.window.open(authUrl.toString(), "OAuthPopup", popupFeatures);
  //
  //     if (popupWindow == null) {
  //       throw Exception("Il pop-up non è stato aperto correttamente.");
  //     }
  //
  //     print("Browser window opened");
  //
  //     // Ascolta per eventi di messaggi postMessage
  //     html.window.onMessage.listen((event) {
  //       // Assicurati che il messaggio sia dal dominio corretto
  //       if (event.origin == authUrl.origin) {
  //         print("Message received from popup");
  //
  //         if (event.data != null) {
  //           // Completa il futuro con il dato ricevuto
  //           completer.complete(event.data);
  //           // Chiudi il pop-up
  //           popupWindow.close();
  //         } else {
  //           completer.completeError("No data received from popup");
  //         }
  //       }
  //     });
  //
  //     return completer.future;
  //   } catch (e) {
  //     print("Errore durante l'apertura della finestra del browser: $e");
  //     completer.completeError(e);
  //     return null;
  //   }
  // }
  //

  // Future<void> createEvent(String accessToken) async {
  //   // Creare un autenticatore con access token
  //   final authClient = authenticatedClient(
  //     http.Client(),
  //     AccessCredentials(
  //       AccessToken('Bearer', accessToken, DateTime.now().toUtc().add(Duration(hours: 1))),
  //       null,
  //       ['https://www.googleapis.com/auth/calendar'],
  //     ),
  //   );
  //
  //   // Inizializzare il servizio calendar
  //   final calendarApi = CalendarApi(authClient);
  //
  //   // Definire un evento
  //   var event = Event()
  //     ..summary = 'Meeting con Team'
  //     ..location = 'Online'
  //     ..description = 'Discussione progetto Flutter'
  //     ..start = (EventDateTime()
  //       ..dateTime = DateTime.parse("2024-11-12T10:00:00Z")
  //       ..timeZone = "GMT+02:00")
  //     ..end = (EventDateTime()
  //       ..dateTime = DateTime.parse("2024-11-12T11:00:00Z")
  //       ..timeZone = "GMT+02:00");
  //
  //   try {
  //     // Aggiungere l'evento al calendario principale
  //     await calendarApi.events.insert(event, "primary");
  //     print("Evento aggiunto con successo");
  //   } catch (e) {
  //     print("Errore durante l'inserimento dell'evento: $e");
  //   }
  // }

  // Future<void> createCalendar2(String accessToken) async {
  //   final authClient = authenticatedClient(
  //     http.Client(),
  //     AccessCredentials(
  //       AccessToken('Bearer', accessToken, DateTime.now().toUtc().add(Duration(hours: 1))),
  //       null,
  //       ['https://www.googleapis.com/auth/calendar'],
  //     ),
  //   );
  //
  //   print("Auth client: $authClient");
  //
  //     final calendarApi = CalendarApi(authClient);
  //
  //     final calendar = Calendar()
  //       ..summary = 'Clanendar di prova'
  //       ..description = 'Un calendario di prova creato tramite Google Calendar API'
  //       ..timeZone = 'Europe/Rome';
  //
  //     print("Calendar: $calendar");
  //
  //     await calendarApi.calendars.insert(calendar).then((value) {
  //       print('Calendario creato con ID: ${value.id}');
  //     }).catchError((e) {
  //       print('Errore durante la creazione del calendario: $e');
  //     });
  // }

  // Future<String> getCalendarIdFromName(String name) async {
  //   final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //   final httpClient = http.Client(await googleUser!.authHeaders);
  //   final CalendarApi calendarAPI = CalendarApi(httpClient);
  //   final CalendarList calendarList = await calendarAPI.calendarList.list();
  //   for (int i = 0; i < calendarList.items!.length; i++) {
  //     if (calendarList.items![i].summary == name) {
  //       return calendarList.items![i].id!;
  //     }
  //   }
  //   return "";
  // }

  static Future<void> getGoogleEventsData() async {
    print("prima riga");
    // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    print("seconda riga");
    // final http.Client httpClient = http.Client(await googleUser!.authHeaders);
    await _googleSignIn.signIn();
    final client = await _googleSignIn.authenticatedClient();
    print("terza riga");
    final CalendarApi calendarApi = CalendarApi(client as http.Client);
    // final CalendarClient calendarClient = CalendarClient();
    // calendarClient._googleSignIn.signInSilently();
    // final CalendarApi calendarAPI = CalendarApi(client);
    print("quarta riga");
    CalendarList calendars = await calendarApi.calendarList.list();
    print("quinta riga");
    String calendarId = '';
    for (int i = 0; i < calendars.items!.length; i++) {
      if (calendars.items![i].summary == 'Ente finto');
      calendarId = calendars.items![i].id!;
    }
    Calendar calendar = await calendarApi.calendars.get(calendarId);
    print("Sesto riga");
    Events events = await calendarApi.events.list(calendarId);
    print("Settimo riga");
    for (int i = 0; i < events.items!.length; i++) {
      print(events.items![i].summary);
      print(events.items![i].id);
    }
    // final Events calEvents = await calendarAPI.events.list(
    //   "primary",
    // );
    // final List<Event> appointments = <Event>[];
    // if (calEvents != null && calEvents.items != null) {
    // for (int i = 0; i < calEvents.items!.length; i++) {
    // final Event event = calEvents.items![i];
    // if (event.start == null) {
    // continue;
    // }
    // appointments.add(event);
    // }
    // }
    // return appointments;
  }
}
