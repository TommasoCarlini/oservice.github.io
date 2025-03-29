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
  DateTime fromDate = DateTime.now().add(Duration(days: 7));

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadLessons();
    _initializeVariables();
  }

  Future<void> _initializeVariables() async {
    await FirebaseHelper.setIsLessonEditing(false);
    await FirebaseHelper.setIsCollaboratorSaved(false);
    await FirebaseHelper.setIsLocationSaved(false);
    await FirebaseHelper.setIsExerciseSaved(false);
    await FirebaseHelper.setIsLessonSaved(false);
    await FirebaseHelper.setIsEntitySaved(false);
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

  Future<void> _loadNextLessons() async {
    try {
      lessons.addAll(await FirebaseHelper.getNextDaysLessons(fromDate));
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
        fromDate = fromDate.add(Duration(days: 7));
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

    void loadMoreLessons() async {
      setState(() {
        isLoading = true;
      });
      await _loadNextLessons();
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
            HomeScreenHeader(width, showIncompleteLessons, showOnlyColab, loadMoreLessons),
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
