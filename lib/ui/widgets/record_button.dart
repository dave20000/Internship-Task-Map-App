import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:app_map/model/map_data.dart';
import 'package:app_map/model/view_model/map_model.dart';
import 'package:app_map/model/view_model/previous_tracks_model.dart';
import 'package:app_map/services/location_callback_handler.dart';
import 'package:app_map/ui/widgets/confirm_button_overlay.dart';

class RecordButton extends StatefulWidget {
  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  //late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(
    //     milliseconds: 450,
    //   ),
    // );
  }

  Future<void> startLocationRecording() async {
    var permissionStatus = await Permission.locationAlways.request();
    if (permissionStatus == PermissionStatus.granted) {
      Map<String, dynamic> data = {'countInit': 1};
      await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 5,
          distanceFilter: 0,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Start Location Tracking',
            notificationMsg: 'Track location in background',
            notificationBigMsg:
                'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
            notificationIcon: '',
            notificationIconColor: Colors.grey,
            notificationTapCallback:
                LocationCallbackHandler.notificationCallback,
          ),
        ),
      );
    } else {
      print("Permission not granted ${permissionStatus.toString()}");
    }
  }

  Future<void> onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final _isRunning = await BackgroundLocator.isServiceRunning();
    print("is service running: " + _isRunning.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviousTrackViewModel>(
      builder: (context, previousTrackViewModel, child) {
        return Consumer<MapViewModel>(
          builder: (context, mapViewModel, child) {
            return GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey.shade300,
                ),
                // child: AnimatedIcon(
                //   icon: AnimatedIcons.play_pause,
                //   progress: _animationController,
                //   size: 30,
                //   color: Colors.white,
                // ),
                child: !mapViewModel.isRecordingStarted
                    ? Icon(
                        Icons.play_arrow,
                        size: 30,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.pause,
                        size: 30,
                        color: Colors.white,
                      ),
              ),
              onTap: () async {
                if (mapViewModel.isMapCleared) {
                  if (mapViewModel.isRecordingStarted) {
                    var isConfirm = await showDialog(
                      context: context,
                      builder: (_) => ConfirmButtonOverlay(),
                    );
                    if (isConfirm != null && isConfirm as bool) {
                      mapViewModel.isRecordingStarted = false;
                      //_animationController.reverse();
                      mapViewModel.isMapCleared = false;
                      await onStop();
                      int len = mapViewModel.locationDtos.length;
                      print("Location dto length: " + len.toString());
                      await mapViewModel.deleteLocationDtoList();
                      mapViewModel.locationDtos = [];
                      await mapViewModel.deleteStartTime();
                      mapViewModel.endTime = DateTime.now();
                      await previousTrackViewModel.insertMapData(
                        MapData(
                          totalDistance: mapViewModel.palaceDistance,
                          startTime: mapViewModel.startTime!,
                          endTime: mapViewModel.endTime!,
                          pointLatLngList: mapViewModel.pointLatLngList,
                        ),
                      );
                    }
                  } else {
                    //_animationController.forward();
                    mapViewModel.isRecordingStarted = true;
                    mapViewModel.palaceDistance = 0;
                    mapViewModel.startTime = DateTime.now();
                    mapViewModel.addStartTime(mapViewModel.startTime!);
                    await startLocationRecording();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Clear map first"),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
