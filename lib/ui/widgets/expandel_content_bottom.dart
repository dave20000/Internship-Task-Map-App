import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_map/model/view_model/map_model.dart';

class ExpandableContentBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Container(
          height: 40,
          color: Colors.blueGrey.shade100,
          child: mapViewModel.locationDto != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Accuracy: " +
                        mapViewModel.locationDto!.accuracy.toStringAsFixed(3)),
                    Text("Speed: " +
                        mapViewModel.locationDto!.speed.toStringAsFixed(3)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Accuracy: --"),
                    Text("Speed --"),
                  ],
                ),
        );
      },
    );
  }
}
