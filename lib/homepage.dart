import 'package:flutter/material.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/footer.dart';
import 'package:oservice/widgets/header/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController tabController;
  List<Menu> menuHistory = [Menu.HOME];
  Menu activeMenu = Menu.HOME;
  Lesson? lesson;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void changeTab(int index) {
      setState(() {
        // NavigationParameters navigationParameters = Menu.fromIndex(index);
        activeMenu = Menu.fromIndex(index);
        if (index < tabController.length) {
          tabController.animateTo(index);
        }
      });
    }

    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/topographic_background_orange.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: Header(tabController, changeTab, context),
            bottomNavigationBar: Footer(tabController, changeTab, context),
            body: Padding(
              padding: const EdgeInsets.all(64.0),
              child: Menu.screenRouting(activeMenu.index, changeTab, tabController),
            ),
          )),
    );
  }
}
