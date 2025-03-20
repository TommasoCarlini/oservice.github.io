import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/utils/responseHandler.dart' as ResponseHandler;

class CalendarClient {

  static final String clientIdKey =
      "835369188362-96p8ueg9tcvko543rmibe10ve17dogk7.apps.googleusercontent.com";
  static final String apiKey = "AIzaSyBiCp5rmAL4hdQIASw5xyepu9uCGUnJgbQ";

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientIdKey,
    scopes: <String>[
      CalendarApi.calendarScope,
      CalendarApi.calendarEventsScope,
    ],
  );

  static Future<ResponseHandler.Result<String>> addCalendar(
      Calendar calendar, String color) async {
    try {
      try {
        if (await _googleSignIn.isSignedIn()) {
        } else {
          await _googleSignIn.signIn();
        }
      } on Exception catch (e) {
        print("Autenticazione fallita: $e");
      }
      final client = await _googleSignIn.authenticatedClient();
      if (client == null) {
        print("Autenticazione fallita: client nullo");
        throw Exception("Autenticazione fallita: client nullo");
      }
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
      Calendar updatedCalendar =
          await calendarApi.calendars.update(calendar, calendarId);
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

  static Future<ResponseHandler.Result<String>> deleteCalendar(
      String calendarId) async {
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

  static Future<ResponseHandler.Result<String>> addEvent(
      Event event, String calendarId) async {
    try {
      await _googleSignIn.signIn();
      final client = await _googleSignIn.authenticatedClient();
      final CalendarApi calendarApi = CalendarApi(client as http.Client);
      bool sendNotification = await FirebaseHelper.getNewEventNotification();
      Event createdEvent = await calendarApi.events
          .insert(event, calendarId, sendNotifications: sendNotification);
      return ResponseHandler.Success(data: createdEvent.id!);
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'evento: $e");
      return ResponseHandler.Error(exception: e);
    }
  }

  static Future<ResponseHandler.Result<String>> updateEvent(
      Event event, String calendarId, String eventId) async {
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

  static Future<ResponseHandler.Result<String>> deleteEvent(
      String calendarId, String eventId) async {
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

  static Future<void> changeCalendarColor(String id, String color) async {
    await _googleSignIn.signIn();
    final client = await _googleSignIn.authenticatedClient();
    final CalendarApi calendarApi = CalendarApi(client as http.Client);
    CalendarListEntry calendars = await calendarApi.calendarList.get(id);
    calendars.backgroundColor = color;
    await calendarApi.calendarList.update(calendars, id, colorRgbFormat: true);
  }
}
