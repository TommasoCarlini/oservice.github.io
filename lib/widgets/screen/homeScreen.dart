import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/card/lessonCard.dart';
import 'package:oservice/widgets/header/homeScreenHeader.dart';

class HomeScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const HomeScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseHelper firebaseHelper;
  List<Lesson> lessons = [];
  List<Lesson> incompleteLessons = [];
  bool isLoading = true;
  bool showIncompleteLessons = false;
  DateTime fromDate = DateTime.now();
  int stepDay = 1;
  DateTime toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadLessons();
    _initializeVariables();
    _loadStepDay();
  }

  Future<void> _initializeVariables() async {
    await FirebaseHelper.setIsLessonEditing(false);
    await FirebaseHelper.setIsCollaboratorSaved(false);
    await FirebaseHelper.setIsLocationSaved(false);
    await FirebaseHelper.setIsExerciseSaved(false);
    await FirebaseHelper.setIsLessonSaved(false);
    await FirebaseHelper.setIsEntitySaved(false);
  }

  Future<void> _loadStepDay() async {
    try {
      stepDay = await FirebaseHelper.getStepDay();
      toDate = DateTime.now().add(Duration(days: stepDay));
    } catch (e) {
      print("Errore durante il caricamento del passo giorno: $e");
    }
  }

  Future<void> _loadLessons() async {
    try {
      lessons = await FirebaseHelper.getAllLessons();
      lessons.sort((a, b) => a.startDate.compareTo(b.startDate));
      incompleteLessons = lessons
          .where(
            (element) => element.isIncomplete(),
          )
          .toList();
    } catch (e) {
      print("Errore durante il caricamento delle lezioni: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    void showOnlyColab(bool value) {
      setState(() {
        showIncompleteLessons = value;
      });
    }

    Future<void> loadNextLessons() async {
      setState(() {
        isLoading = true;
      });
      try {
        lessons.addAll(await FirebaseHelper.getNextDaysLessons(toDate));
        lessons.sort((a, b) => a.startDate.compareTo(b.startDate));
        incompleteLessons = lessons
            .where(
              (element) => element.isIncomplete(),
        )
            .toList();
      } catch (e) {
        print("Errore durante il caricamento delle lezioni: $e");
      } finally {
        setState(() {
          toDate = toDate.add(Duration(days: stepDay));
          isLoading = false;
        });
      }
    }

    Future<void> loadLessonsBetweenDates(
        DateTime fromDate, DateTime toDate) async {
      setState(() {
        isLoading = true;
        this.fromDate = fromDate;
        this.toDate = toDate;
      });
      try {
        lessons = await FirebaseHelper.getLessonsBetweenDates(
            fromDate, toDate.add(Duration(hours: 23)));
        lessons.sort((a, b) => a.startDate.compareTo(b.startDate));
        incompleteLessons = lessons
            .where(
              (element) => element.isIncomplete(),
            )
            .toList();
      } catch (e) {
        print("Errore durante il caricamento delle lezioni: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    void dateRangePicker() async {
      DateTimeRange? pickedDateRange = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.deepOrangeAccent,
                onSurface: Colors.black87,
                onPrimary: Colors.black87,
              ),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.deepOrangeAccent,
                selectionColor: Colors.deepOrangeAccent,
                selectionHandleColor: Colors.deepOrangeAccent,
              ),
            ),
            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 600.0,
                  width: 400.0,
                  child: DateRangePickerDialog(
                      firstDate: DateTime(DateTime.now().year),
                      lastDate: DateTime(DateTime.now().year + 2)),
                )),
          );
        },
      );
      if (pickedDateRange != null) {
        setState(() {
          fromDate = pickedDateRange.start;
          toDate = pickedDateRange.end;
          loadLessonsBetweenDates(fromDate, toDate);
        });
      }
      return;
    }

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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            HomeScreenHeader(width, showIncompleteLessons, showOnlyColab,
                fromDate, toDate, loadNextLessons, dateRangePicker, stepDay.toString()),
            Expanded(
              // Usa Expanded qui
              child: ListView.builder(
                padding: const EdgeInsets.all(18.0),
                itemCount: showIncompleteLessons
                    ? incompleteLessons.length
                    : lessons.length,
                itemBuilder: (context, index) {
                  return LessonCard(
                      changeTab: widget.changeTab,
                      menu: widget.menu,
                      lesson: showIncompleteLessons
                          ? incompleteLessons[index]
                          : lessons[index],
                      refreshLessons: _loadLessons);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.add_circle_outline_rounded),
                iconSize: width / 40,
                color: Colors.indigo,
                onPressed: () {
                  widget.changeTab(Menu.AGGIUNGI_LEZIONE.index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
