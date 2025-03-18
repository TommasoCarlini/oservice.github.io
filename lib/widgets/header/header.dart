import 'package:flutter/material.dart';
import 'package:oservice/constants/constants.dart';
import 'package:oservice/enums/menu.dart';

PreferredSizeWidget? Header(TabController tabController, Function changeTab, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return width >= Constants.MAX_WIDTH_NAVBAR
      ? AppBar(
          backgroundColor: Colors.black87,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Image.asset(
                'images/logo_header-removebg.png',
                height: 40,
              ),
              const SizedBox(width: 160),
              Expanded(
                child: TabBar(
                  onTap: (index) {
                    changeTab(index);
                  },
                  controller: tabController,
                  indicatorColor: Theme.of(context).primaryColorDark,
                  labelColor: Theme.of(context).primaryColorDark,
                  unselectedLabelColor: Colors.white70,
                  dividerColor: Colors.black,
                  overlayColor: WidgetStateProperty.all(
                      const Color.fromRGBO(253, 128, 40, 0.25)),
                  tabs: [
                    Tab(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          const Icon(Icons.home),
                          const SizedBox(width: 10),
                          Text(Menu.HOME.value)
                        ])),
                    Tab(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          const Icon(Icons.blinds_outlined),
                          const SizedBox(width: 10),
                          Text(Menu.ENTI.value)
                        ])),
                    Tab(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          const Icon(Icons.people_alt_rounded),
                          const SizedBox(width: 10),
                          Text(Menu.COLLABORATORI.value)
                        ])),
                    Tab(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          const Icon(Icons.archive_rounded),
                          const SizedBox(width: 10),
                          Text(Menu.ARCHIVIO.value)
                        ])),
                    Tab(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          const Icon(Icons.settings),
                          const SizedBox(width: 10),
                          Text(Menu.IMPOSTAZIONI.value)
                        ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      : null;
}
