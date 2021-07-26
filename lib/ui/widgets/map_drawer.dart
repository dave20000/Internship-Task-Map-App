import 'dart:ui';

import 'package:app_map/model/view_model/previous_tracks_model.dart';
import 'package:app_map/ui/screens/map_preview_screen.dart';
import 'package:flutter/material.dart';

import 'package:app_map/model/map_data.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class MapDrawer extends StatefulWidget {
  @override
  _MapDrawerState createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer> {
  int _selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Consumer<PreviousTrackViewModel>(
      builder: (context, previousTrackViewModel, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.blueGrey.shade100,
          ),
          child: Drawer(
            child: previousTrackViewModel.mapDatas.length == 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBar(
                        title: Text("Past Trip Data"),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Center(
                        child: Text("No tracking history avaialable"),
                      ),
                      SizedBox(),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBar(
                        title: Text("Past Trip Data"),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: previousTrackViewModel.mapDatas.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                width: 2,
                                color: Colors.grey.shade400,
                              )),
                              child:
                                  // Column(
                                  //   children: [
                                  ListTile(
                                // trailing: PopupMenuButton<String>(
                                //   onSelected: (value) {
                                //     switch (value) {
                                //       case 'Map':
                                //         Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //             builder: (context) =>
                                //                 MapPreviewScreen(
                                //               mapData: previousTrackViewModel
                                //                   .mapDatas[index],
                                //             ),
                                //           ),
                                //         );
                                //         break;
                                //       case 'Delete':
                                //         showDialog(
                                //           context: context,
                                //           builder: (BuildContext context) {
                                //             return AlertDialog(
                                //               title: Text("Delete"),
                                //               content: Text(
                                //                 "Are you sure you want to delete?",
                                //               ),
                                //               actions: [
                                //                 TextButton(
                                //                   child: Text("Cancel"),
                                //                   onPressed: () {
                                //                     Navigator.pop(context);
                                //                   },
                                //                 ),
                                //                 TextButton(
                                //                   child: Text("Continue"),
                                //                   onPressed: () {
                                //                     Navigator.pop(context);
                                //                   },
                                //                 ),
                                //               ],
                                //             );
                                //           },
                                //         );
                                //         break;
                                //     }
                                //   },
                                //   itemBuilder: (BuildContext context) {
                                //     return _selectedIndex == index
                                //         ? {'Map', 'Delete'}
                                //             .map((String choice) {
                                //             return PopupMenuItem<String>(
                                //               value: choice,
                                //               child: Text(choice),
                                //             );
                                //           }).toList()
                                //         : [];
                                //   },
                                // ),
                                trailing: IconButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    if (_selectedIndex == index) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MapPreviewScreen(
                                            mapData: previousTrackViewModel
                                                .mapDatas[index],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.map),
                                ),
                                title: Text(
                                  'Start Date: ${Jiffy(previousTrackViewModel.mapDatas[index].startTime).format("MMMM do yyyy, h:mm:ss a")}',
                                  textScaleFactor: 1.2,
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${previousTrackViewModel.mapDatas[index].totalDistance.toStringAsFixed(2)} Km',
                                      textScaleFactor: 1.2,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      "Time ${(previousTrackViewModel.mapDatas[index].endTime.difference(previousTrackViewModel.mapDatas[index].startTime)).toString().split('.').first.padLeft(8, "0")}",
                                      textScaleFactor: 1.2,
                                    ),
                                  ],
                                ),
                                selected: _selectedIndex == index,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                              ),
                              // _selectedIndex == index
                              //     ? Row(
                              //         children: [
                              //           IconButton(
                              //             padding: EdgeInsets.all(0),
                              //             onPressed: () {
                              //               if (_selectedIndex == index) {
                              //                 Navigator.push(
                              //                   context,
                              //                   MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         MapPreviewScreen(
                              //                       mapData:
                              //                           widget.mapData[index],
                              //                     ),
                              //                   ),
                              //                 );
                              //               }
                              //             },
                              //             icon: Icon(Icons.map),
                              //           ),
                              //           IconButton(
                              //             padding: EdgeInsets.all(0),
                              //             onPressed: () {
                              //               if (_selectedIndex == index) {
                              //                 Navigator.push(
                              //                   context,
                              //                   MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         MapPreviewScreen(
                              //                       mapData:
                              //                           widget.mapData[index],
                              //                     ),
                              //                   ),
                              //                 );
                              //               }
                              //             },
                              //             icon: Icon(Icons.delete),
                              //           ),
                              //         ],
                              //       )
                              //     : SizedBox(),
                              //],
                              //),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text(
        "Are you sure you want to delete?",
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
