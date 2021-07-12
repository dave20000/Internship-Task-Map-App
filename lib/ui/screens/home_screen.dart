import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'package:app_map/model/view_model/map_model.dart';
import 'package:app_map/ui/screens/map_page.dart';
import 'package:app_map/ui/screens/result_page.dart';
import 'package:app_map/ui/widgets/base_widget.dart';

class HomeScreen extends StatelessWidget {
  final List<Widget> pages = [MapPage(), ResultPage()];

  @override
  Widget build(BuildContext context) {
    return BaseWidget<MapViewModel>(
      onModelReady: (mapViewModel) async {
        LocationData location = await Location().getLocation();
        mapViewModel.initialLocation = CameraPosition(
          target: LatLng(
            location.latitude!,
            location.longitude!,
          ),
          zoom: 11.5,
        );
      },
      builder: (context, mapViewModel, child) {
        return SafeArea(
          child: Scaffold(
            body: Consumer<MapViewModel>(
              builder: (context, mapViewModel, child) {
                // return child: pages[mapViewModel.currentIndex];
                return IndexedStack(
                  index: mapViewModel.currentIndex,
                  children: pages,
                );
              },
            ),
            appBar: AppBar(
              title: Text("Map App"),
            ),
            drawer: Drawer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('This is the Drawer'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close Drawer'),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: mapViewModel.currentIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Map",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.details),
                  label: "Details",
                ),
              ],
              onTap: (index) {
                mapViewModel.currentIndex = index;
              },
            ),
          ),
        );
      },
    );
  }
}
