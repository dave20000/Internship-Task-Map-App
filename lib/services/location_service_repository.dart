import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_map/model/map_data.dart';
import 'package:app_map/services/databases/database_history_service.dart';
import 'package:app_map/services/databases/database_start_time.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';

import 'package:app_map/services/app_constants.dart';
import 'package:app_map/services/databases/database_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  MapLocationDatabaseService mapLocationDatabaseService =
      MapLocationDatabaseService();

  // DatabaseHistoryService databaseHistoryService = DatabaseHistoryService();
  // DataBaseStartTimeService dataBaseStartTimeService =
  //     DataBaseStartTimeService();

  Future<void> init(Map<dynamic, dynamic> params) async {
    print("***********Init callback handler");
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send!.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send!.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    await mapLocationDatabaseService.insertLocationDto(locationDto);
    _updateNotificationText(locationDto);
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send?.send(locationDto);
    // bool isGiven = await _checkPermissionStatus();
    // print("Location callback cheking permission given :" + isGiven.toString());
    // if (isGiven) {
    //   await mapLocationDatabaseService.insertLocationDto(locationDto);
    //   _updateNotificationText(locationDto);
    //   final SendPort? send =
    //       IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    //   send?.send(locationDto);
    // } else {
    //   onStop();
    //   var locDtos = await mapLocationDatabaseService.getLocations();
    //   List<LatLng> pointLatLngList = [];
    //   locDtos.forEach((element) {
    //     pointLatLngList.add(LatLng(element.latitude, element.longitude));
    //   });
    //   print("Location dto length: " + locDtos.toString());
    //   await mapLocationDatabaseService.deleteLocations();
    //   databaseHistoryService.insertMapData(
    //     MapData(
    //       totalDistance: 0,
    //       startTime: await dataBaseStartTimeService.getStartTime(),
    //       endTime: DateTime.now(),
    //       pointLatLngList: pointLatLngList,
    //     ),
    //   );
    // }
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    await BackgroundLocator.updateNotificationText(
      title: "Map App",
      // msg:
      //     "Time Elapsed: ${(DateTime.now().difference(DateTime.parse(data.time.toString()))).toString().split('.').first.padLeft(8, "0")}",
      msg: "${(DateTime.now())}",
      bigMsg: "Lat: ${data.latitude},Lon: ${data.longitude}",
    );
  }
}
