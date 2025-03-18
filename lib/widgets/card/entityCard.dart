import 'package:flutter/material.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/widgets/card/entityCardAction.dart';
import 'package:url_launcher/url_launcher.dart';

class EntityCard extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Entity entity;
  final Future<void> Function() refreshEntities;

  const EntityCard({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.entity,
    required this.refreshEntities,
  });

  @override
  _EntityCardState createState() => _EntityCardState();
}

class _EntityCardState extends State<EntityCard> {
  @override
  Widget build(BuildContext context) {
    Color color = Color(
        int.parse(widget.entity.color.substring(1, 7), radix: 16) + 0xFF000000);

    bool isDark(Color color) {
      double luminance =
          (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
      return luminance < 0.5;
    }

    Color iconColor = isDark(color) ? Colors.white : Colors.black;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Theme.of(context).cardColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(Icons.location_city_rounded, color: iconColor),
        ),
        title: Row(
          children: [
            Text(
              widget.entity.name,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10)
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: Theme.of(context).primaryColorLight),
                TextButton(
                  child: Text(
                    '${widget.entity.location.address} - ${widget.entity.location.city}',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(widget.entity.location.href);
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColorLight),
                TextButton(
                  child: Text(
                    '${widget.entity.referee.name} - ${widget.entity.referee.phone}',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(
                        'https://api.whatsapp.com/send/?phone=${widget.entity.referee.phone.replaceAll(' ', '')}');
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: EntityCardAction(
            changeTab: widget.changeTab,
            menu: widget.menu,
            entity: widget.entity,
            refreshEntities: widget.refreshEntities,
        ),
      ),
    );
  }
}
