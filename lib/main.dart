import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O-Service Manager App',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('it'),
      ],
      color: Colors.orange,
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
        primarySwatch: Colors.orange,
        fontFamily: 'Montserrat',
        primaryColorDark: Colors.orange,
        primaryColorLight: Colors.indigo.shade800,
        secondaryHeaderColor: Colors.blueGrey.shade700,
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.indigo.shade800,
            secondary: Colors.indigo.shade800,
          ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.green),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
        ),
        buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
          ),
          buttonColor: Colors.orange,
          textTheme: ButtonTextTheme.primary,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(Colors.white),
          side: BorderSide(
            color: Colors.orange,
            width: 2.0,
          ),
          checkColor: WidgetStateProperty.all(Colors.green),
          overlayColor: WidgetStateProperty.all(Colors.orange),
        ),
        primaryTextTheme: TextTheme(
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
          labelMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
          labelSmall: TextStyle(
            fontSize: 14,
            color: Colors.orange,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
