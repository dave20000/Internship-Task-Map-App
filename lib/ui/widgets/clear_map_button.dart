import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_map/model/view_model/map_model.dart';

class ClearMapButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return AnimatedOpacity(
          opacity: mapViewModel.isMapCleared ? 0 : 1,
          duration: Duration(
            milliseconds: 450,
          ),
          child: GestureDetector(
            onTap: () {
              mapViewModel.marker = null;
              mapViewModel.polyline = {};
              mapViewModel.palaceDistance = 0;
              mapViewModel.locationDto = null;
              mapViewModel.pointLatLngList = [];
              mapViewModel.isMapCleared = true;
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey.shade300,
              ),
              child: Icon(
                Icons.clear,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
