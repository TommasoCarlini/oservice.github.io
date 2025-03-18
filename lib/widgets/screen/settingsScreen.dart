import 'package:flutter/material.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/widgets/buttons/squaredButton.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const SettingsScreen(
      {super.key, required this.changeTab, required this.menu});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String url = 'https://calendar.google.com/calendar/u/0/r';

  Future<void> _launchUrl() async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 30,),
                  Column(
                    children: [
                      SquaredButton(
                        onPressed: () {
                          widget.changeTab(Menu.PAYMENTS.index);
                          Menu.screenRouting(Menu.PAYMENTS.index,
                              widget.changeTab, widget.menu);
                        },
                        icon: Icons.euro_rounded,
                        text: "Economia",
                      ),
                      SquaredButton(
                        onPressed: () {
                          widget.changeTab(Menu.LUOGHI.index);
                          Menu.screenRouting(
                              Menu.LUOGHI.index, widget.changeTab, widget.menu);
                        },
                        icon: Icons.location_on_rounded,
                        text: "Luoghi",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SquaredButton(
                        onPressed: () {
                          widget.changeTab(Menu.LEZIONI_NON_CONVALIDATE.index);
                          Menu.screenRouting(Menu.LEZIONI_NON_CONVALIDATE.index,
                              widget.changeTab, widget.menu);
                        },
                        icon: Icons.playlist_add_check,
                        text: "Da approvare",
                      ),
                      SquaredButton(
                        onPressed: () {
                          widget.changeTab(Menu.ESERCIZI.index);
                          Menu.screenRouting(
                              Menu.ESERCIZI.index, widget.changeTab, widget.menu);
                        },
                        icon: Icons.fitness_center_rounded,
                        text: "Esercizi",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SquaredButton(
                        onPressed: () {
                          widget.changeTab(Menu.NOTIFICATIONS.index);
                          Menu.screenRouting(Menu.NOTIFICATIONS.index,
                              widget.changeTab, widget.menu);
                        },
                        icon: Icons.notifications_active_rounded,
                        text: "Notifiche",
                      ),
                      SquaredButton(
                        onPressed: () {
                          _launchUrl();
                        },
                        icon: Icons.calendar_month_rounded,
                        text: "Calendario",
                      ),
                    ],
                  ),
                  SizedBox(width: 30,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
