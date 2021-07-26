import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_map/services/app_constants.dart';
import 'package:app_map/services/databases/database_service.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  MapLocationDatabaseService mapLocationDatabaseService =
      MapLocationDatabaseService();

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send!.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send!.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    //print('$_count location in dart: ${locationDto.toString()}');
    await mapLocationDatabaseService.insertLocationDto(locationDto);
    _updateNotificationText(locationDto);
    // print(
    //   locationDto.latitude.toString() +
    //       " " +
    //       locationDto.longitude.toString() +
    //       " " +
    //       locationDto.speed.toString(),
    // );
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send?.send(locationDto);
    _count++;
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    await BackgroundLocator.updateNotificationText(
      title: "new location received",
      msg: "${DateTime.now()}",
      bigMsg: "${data.latitude}, ${data.longitude}",
    );
  }
}
