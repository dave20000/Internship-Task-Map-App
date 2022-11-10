import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/location_dto.dart';
import 'package:flutter/widgets.dart';

import 'package:app_map/services/app_constants.dart';
import 'package:app_map/services/databases/database_service.dart';

class BackgroundTrackViewModel extends ChangeNotifier {
  MapLocationDatabaseService _mapLocationDatabaseService;
  BackgroundTrackViewModel(this._mapLocationDatabaseService);

  int _count = -1;
  Future<void> initCallback(Map<dynamic, dynamic> params) async {
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

  Future<void> disposeCallback() async {
    print("$_count");
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send!.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('$_count location in dart: ${locationDto.toString()}');
    await _mapLocationDatabaseService.insertLocationDto(locationDto);
    final SendPort? send =
        IsolateNameServer.lookupPortByName(AppConstants.isolateName);
    send?.send(locationDto);
    _count++;
  }

  Future<void> notificationCallback() async {
    print('***notificationCallback');
  }

  Future<List<LocationDto>> fetchLocationsDtos() async {
    return await _mapLocationDatabaseService.getLocations();
  }

  Future<void> clearLocationDtos() async {
    await _mapLocationDatabaseService.deleteLocations();
  }
}
