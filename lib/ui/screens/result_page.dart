import 'package:app_map/model/view_model/map_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: mapViewModel.palaceDistance != null
                    ? Text(
                        "Distance Covered : " +
                            mapViewModel.palaceDistance.toString(),
                        style: TextStyle(fontSize: 22),
                      )
                    : Text(
                        "Please Start Recording first to see distance",
                        style: TextStyle(fontSize: 22),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "Details",
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Latitude',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'longitude',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Accuracy',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: <DataRow>[
                    mapViewModel.locationData != null
                        ? DataRow(
                            cells: <DataCell>[
                              DataCell(Text(mapViewModel.locationData.latitude
                                  .toString())),
                              DataCell(Text(mapViewModel.locationData.longitude
                                  .toString())),
                              DataCell(Text(mapViewModel.locationData.accuracy
                                  .toString())),
                            ],
                          )
                        : DataRow(
                            cells: <DataCell>[
                              DataCell(Text("...")),
                              DataCell(Text("...")),
                              DataCell(Text("...")),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
