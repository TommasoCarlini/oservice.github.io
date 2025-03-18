import 'package:flutter/material.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/widgets/card/archiveCardAction.dart';
import 'package:url_launcher/url_launcher.dart';

class ArchiveCard extends StatefulWidget {
  final Lesson lesson;
  final Function changeTab;
  final TabController menu;
  final Function refreshLessons;

  const ArchiveCard({
    super.key,
    required this.lesson,
    required this.changeTab,
    required this.menu,
    required this.refreshLessons,
  });

  @override
  _ArchiveCardState createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<ArchiveCard> {
  @override
  Widget build(BuildContext context) {
    Color color = Color(
        int.parse(widget.lesson.entity.color.substring(1, 7), radix: 16) +
            0xFF000000);

    bool isDark(Color color) {
      double luminance =
          (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
      return luminance < 0.5;
    }

    Color iconColor = isDark(color) ? Colors.white : Colors.black;

    bool isCollaboratorSufficient =
        widget.lesson.collaborators.length < widget.lesson.collaboratorsNeeded;
    bool isSchoolCamp =
        widget.lesson.startDate.day != widget.lesson.endDate.day;

    String aroundMinutes(int minutes) {
      int roundedMinutes = ((minutes / 15).round() * 15) % 60;
      return roundedMinutes < 10
          ? '0$roundedMinutes'
          : roundedMinutes.toString();
    }

    String buildCollaboratorsText() {
      try {
        if (widget.lesson.collaborators.length == 1) {
          return widget.lesson.collaborators.first.nickname!;
        }
        return widget.lesson.responsible != null
            ? "${widget.lesson.responsible?.nickname} (Resp.), ${widget.lesson.collaborators.map((e) {
          return e.name == widget.lesson.responsible?.name
              ? ""
              : e.nickname;
        }).join(", ")}"
            : widget.lesson.collaborators.map((e) => e.nickname).join(", ");
      } catch (e) {
        return widget.lesson.collaborators.map((e) => e.nickname).join(", ");
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Theme.of(context).cardColor,
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  child: Icon(Icons.blinds_outlined, color: iconColor),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.lesson.title} - ${widget.lesson.entity.name}",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_city_rounded,
                            color: Theme.of(context).primaryColorLight),
                        TextButton(
                          child: Text(
                            widget.lesson.entity.name,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight),
                          ),
                          onPressed: () async {},
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: Theme.of(context).primaryColorLight),
                        TextButton(
                          child: Text(
                            '${widget.lesson.location.address} - ${widget.lesson.location.city}',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight),
                          ),
                          onPressed: () async {
                            final Uri url =
                            Uri.parse(widget.lesson.location.href);
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Theme.of(context).primaryColorLight),
                        SizedBox(width: 10),
                        Text(
                            "${widget.lesson.startDate.day}/${widget.lesson.startDate.month}/${widget.lesson.startDate.year}",
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                            isSchoolCamp
                                ? Icons.calendar_month_rounded
                                : Icons.access_time_rounded,
                            color: Theme.of(context).primaryColorLight),
                        SizedBox(width: 10),
                        Text(
                            isSchoolCamp
                                ? "${widget.lesson.endDate.day}/${widget.lesson.endDate.month}/${widget.lesson.endDate.year}"
                                : "${widget.lesson.startDate.hour}:${aroundMinutes(widget.lesson.startDate.minute)} - ${widget.lesson.endDate.hour}:${aroundMinutes(widget.lesson.endDate.minute)}",
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                )),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                          isCollaboratorSufficient
                              ? Icons.person_search_rounded
                              : Icons.people_alt_rounded,
                          color: isCollaboratorSufficient
                              ? Colors.red.shade700
                              : Colors.green.shade700),
                      SizedBox(width: 10),
                      Text(
                          isCollaboratorSufficient
                              ? "Trova altri collaboratori!"
                              : "Collaboratori ok",
                          style: TextStyle(
                              color: isCollaboratorSufficient
                                  ? Colors.red.shade700
                                  : Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Tooltip(
                      message: buildCollaboratorsText().replaceAll(", ,", ","),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: Theme.of(context).primaryTextTheme.labelSmall,
                      child: Text(
                        "Collaboratori: ${widget.lesson.collaborators.length} su ${widget.lesson.collaboratorsNeeded}",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      ))
                ],
              ),
            ),
            ArchiveCardAction(
                changeTab: widget.changeTab,
                menu: widget.menu,
                lesson: widget.lesson,
                refreshLessons: widget.refreshLessons),
          ],
        ),
      ),
    );
  }
}