import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/card/archiveCard.dart';

class ArchiveScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const ArchiveScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late FirebaseHelper firebaseHelper;
  late List<Lesson> lessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      await FirebaseHelper.setIsLessonEditing(false);
      lessons = await FirebaseHelper.getAllPastLessons();
      lessons.sort((a, b) => a.startDate.compareTo(b.startDate));
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
            Expanded(
              // Usa Expanded qui
              child: ListView.builder(
                padding: const EdgeInsets.all(18.0),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  return ArchiveCard(
                      changeTab: widget.changeTab,
                      menu: widget.menu,
                      lesson: lessons[index],
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
