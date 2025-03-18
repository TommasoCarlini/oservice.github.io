import 'package:flutter/material.dart';
import 'package:oservice/entities/location.dart';
import 'package:oservice/widgets/card/locationCardAction.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationCard extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Location location;
  final Future<void> Function() refreshLocations;

  const LocationCard({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.location,
    required this.refreshLocations,
  });

  @override
  _LocationCardState createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Theme.of(context).cardColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.share_location_rounded),
        ),
        title: Row(
          children: [
            Text(
              widget.location.title,
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
                    '${widget.location.address} - ${widget.location.city}',
                    style:
                    TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(widget.location.href);
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                ),
              ],
            ),
            // Row(
            //   children: [
            //     Icon(Icons.person, color: Theme.of(context).primaryColorLight),
            //     TextButton(
            //       child: Text(
            //         '${widget.location.referee.name} - ${widget.location.referee.phone}',
            //         style:
            //         TextStyle(color: Theme.of(context).primaryColorLight),
            //       ),
            //       onPressed: () async {
            //         final Uri url = Uri.parse(
            //             'https://api.whatsapp.com/send/?phone=${widget.location.referee.phone.replaceAll(' ', '')}');
            //         if (!await launchUrl(url)) {
            //           throw Exception('Could not launch $url');
            //         }
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
        trailing: LocationCardAction(
          changeTab: widget.changeTab,
          menu: widget.menu,
          location: widget.location,
          refreshLocations: widget.refreshLocations,
        ),
      ),
    );
  }
}
