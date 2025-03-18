import 'package:flutter/material.dart';
import 'package:oservice/constants/constants.dart';

Widget? Footer(TabController tabController, Function changeTab, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return width < Constants.MAX_WIDTH_NAVBAR
      ? NavigationBar(
          backgroundColor: Colors.black87,
          indicatorColor: Colors.black12,
          overlayColor:
              WidgetStateProperty.all(const Color.fromRGBO(253, 128, 40, 0.25)),
          onDestinationSelected: (int index) {
            changeTab(index);
          },
          destinations: [
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.home, color: Theme.of(context).primaryColorDark),
              icon: const Icon(Icons.home,
                  color: Color.fromRGBO(253, 128, 40, 0.5)),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.blinds_outlined,
                  color: Theme.of(context).primaryColorDark),
              icon: const Icon(Icons.blinds_outlined,
                  color: Color.fromRGBO(253, 128, 40, 0.5)),
              label: 'Enti',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.people_alt_rounded,
                  color: Theme.of(context).primaryColorDark),
              icon: const Icon(Icons.people_alt_rounded,
                  color: Color.fromRGBO(253, 128, 40, 0.5)),
              label: 'Collaboratori',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.archive_rounded,
                  color: Theme.of(context).primaryColorDark),
              icon: const Icon(Icons.archive_rounded,
                  color: Color.fromRGBO(253, 128, 40, 0.5)),
              label: 'Archivio',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings,
                  color: Theme.of(context).primaryColorDark),
              icon: const Icon(Icons.settings,
                  color: Color.fromRGBO(253, 128, 40, 0.5)),
              label: 'Impostazioni',
            ),
          ],
        )
      : null;
}
