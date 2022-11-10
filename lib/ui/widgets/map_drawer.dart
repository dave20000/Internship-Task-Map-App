import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import 'package:app_map/model/view_model/previous_tracks_model.dart';
import 'package:app_map/ui/screens/map_preview_screen.dart';

class MapDrawer extends StatefulWidget {
  @override
  _MapDrawerState createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer> {
  late final SlidableController slidableController;
  int _selectedIndex = -1;
  @override
  void initState() {
    slidableController = SlidableController();
    super.initState();
  }

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
                ? Center(
                    child: Text(
                      "No tracking history avaialable",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: previousTrackViewModel.mapDatas.length,
                    itemBuilder: (context, index) {
                      return Slidable.builder(
                        key: Key(index.toString()),
                        controller: slidableController,
                        actionPane: SlidableScrollActionPane(),
                        actionExtentRatio: 0.25,
                        secondaryActionDelegate: SlideActionBuilderDelegate(
                          actionCount: 1,
                          builder: (context, index, animation, renderingMode) {
                            return IconSlideAction(
                              caption: 'Delete',
                              color:
                                  renderingMode == SlidableRenderingMode.slide
                                      ? Colors.red.withOpacity(animation!.value)
                                      : Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                print("delete pressed");
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete"),
                                      content: Text(
                                        "Are you sure you want to delete ${Jiffy(previousTrackViewModel.mapDatas[index].startTime).format("MMMM do yyyy, h:mm:ss a")} track data?",
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: Text("Continue"),
                                          onPressed: () async {
                                            await previousTrackViewModel
                                                .deleteMapData(
                                                    previousTrackViewModel
                                                        .mapDatas[index]);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              closeOnTap: true,
                            );
                          },
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 2,
                            color: Colors.grey.shade400,
                          )),
                          child: ListTile(
                            trailing: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                if (_selectedIndex == index) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapPreviewScreen(
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
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
