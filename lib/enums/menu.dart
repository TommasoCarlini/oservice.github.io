import 'package:flutter/material.dart';
import 'package:oservice/widgets/screen/addCollaboratorScreen.dart';
import 'package:oservice/widgets/screen/addEntityScreen.dart';
import 'package:oservice/widgets/screen/addExerciseScreen.dart';
import 'package:oservice/widgets/screen/addLessonScreen.dart';
import 'package:oservice/widgets/screen/addLocationScreen.dart';
import 'package:oservice/widgets/screen/collaboratorScreen.dart';
import 'package:oservice/widgets/screen/entityScreen.dart';
import 'package:oservice/widgets/screen/exerciseScreen.dart';
import 'package:oservice/widgets/screen/homeScreen.dart';
import 'package:oservice/widgets/screen/locationScreen.dart';
import 'package:oservice/widgets/screen/notificationScreen.dart';
import 'package:oservice/widgets/screen/paymentsScreen.dart';
import 'package:oservice/widgets/screen/registrationScreen.dart';
import 'package:oservice/widgets/screen/settingsScreen.dart';
import 'package:oservice/widgets/screen/archiveScreen.dart';
import 'package:oservice/widgets/screen/unpaidScreen.dart';

class Menu {
  final String value;
  final int index;

  const Menu._(this.value, this.index);

  static const Menu HOME = Menu._('Home', 0);
  static const Menu ENTI = Menu._('Enti', 1);
  static const Menu COLLABORATORI = Menu._('Collaboratori', 2);
  static const Menu ARCHIVIO = Menu._('Archivio', 3);
  static const Menu IMPOSTAZIONI = Menu._('Impotazioni', 4);
  static const Menu AGGIUNGI_LEZIONE = Menu._('Aggiungi una lezione', 5);
  static const Menu AGGIUNGI_ENTE = Menu._('Aggiungi un ente', 6);
  static const Menu AGGIUNGI_COLLABORATORE =
      Menu._('Aggiungi un collaboratore', 7);
  static const Menu AGGIUNGI_ESERCIZIO = Menu._('Aggiungi un esercizio', 8);
  static const Menu AGGIUNGI_LOCATION = Menu._('Aggiungi una location', 9);
  static const Menu LUOGHI = Menu._('Luoghi', 10);
  static const Menu ESERCIZI = Menu._('Esercizi', 11);
  static const Menu CONVALIDA_LEZIONE = Menu._('Convalida una lezione', 12);
  static const Menu LEZIONI_NON_CONVALIDATE =
      Menu._('Lezioni non convalidate', 13);
  static const Menu PAYMENTS = Menu._('Pagamenti', 14);
  static const Menu NOTIFICATIONS = Menu._('Notifiche', 15);

  static Menu fromIndex(int index) {
    switch (index) {
      case 0:
        return HOME;
      case 1:
        return ENTI;
      case 2:
        return COLLABORATORI;
      case 3:
        return ARCHIVIO;
      case 4:
        return IMPOSTAZIONI;
      case 5:
        return AGGIUNGI_LEZIONE;
      case 6:
        return AGGIUNGI_ENTE;
      case 7:
        return AGGIUNGI_COLLABORATORE;
      case 8:
        return AGGIUNGI_ESERCIZIO;
      case 9:
        return AGGIUNGI_LOCATION;
      case 10:
        return LUOGHI;
      case 11:
        return ESERCIZI;
      case 12:
        return CONVALIDA_LEZIONE;
      case 13:
        return LEZIONI_NON_CONVALIDATE;
      case 14:
        return PAYMENTS;
      case 15:
        return NOTIFICATIONS;
      default:
        return HOME;
    }
  }

  static screenRouting(
      int index, Function changeTab, TabController tabController) {
    switch (index) {
      case 0:
        return HomeScreen(changeTab: changeTab, menu: tabController);
      case 1:
        return EntityScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 2:
        return CollaboratorScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 3:
        return ArchiveScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 4:
        return SettingsScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 5:
        return AddLessonScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 6:
        return AddEntityScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 7:
        return AddCollaboratorScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 8:
        return AddExerciseScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 9:
        return AddLocationScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 10:
        return LocationScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 11:
        return ExerciseScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 12:
        return RegistrationScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 13:
        return UnpaidScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 14:
        return PaymentsScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      case 15:
        return NotificationScreen(
          changeTab: changeTab,
          menu: tabController,
        );
      default:
        return HomeScreen(
          changeTab: changeTab,
          menu: tabController,
        );
    }
  }
}
