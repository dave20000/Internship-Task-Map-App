import 'package:app_map/model/view_model/map_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersistentHeaderBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Container(
          height: 60,
          color: Colors.blueGrey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Distance Covered: " + mapViewModel.palaceDistance.toString(),
              ),
              mapViewModel.locationDto != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Latitiude: " +
                            mapViewModel.locationDto!.latitude.toString()),
                        Text("Longitude: --" +
                            mapViewModel.locationDto!.longitude.toString()),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Latitiude: --"),
                        Text("Longitude: --"),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}
