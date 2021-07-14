import 'package:app_map/ui/screens/map_preview_screen.dart';
import 'package:flutter/material.dart';

import 'package:app_map/model/map_data.dart';
import 'package:jiffy/jiffy.dart';

class MapDrawer extends StatelessWidget {
  final List<MapData> mapData;
  const MapDrawer({
    required this.mapData,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemCount: mapData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPreviewScreen(
                      latLngPoints: mapData[index].pointLatLngList,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Track ${index + 1}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Start Time ${Jiffy(mapData[index].startTime).format("MMMM do yyyy, h:mm:ss a")}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "End Time ${Jiffy(mapData[index].endTime).format("MMMM do yyyy, h:mm:ss a")}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Track Time ${(mapData[index].endTime.difference(mapData[index].startTime)).toString().split('.').first.padLeft(8, "0")}",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
