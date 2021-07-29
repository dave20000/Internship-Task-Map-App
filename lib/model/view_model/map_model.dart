import 'package:background_locator/location_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app_map/services/databases/database_service.dart';
import 'package:app_map/services/databases/database_start_time.dart';
import 'package:slidable_button/slidable_button.dart';

class MapViewModel extends ChangeNotifier {
  MapLocationDatabaseService _mapLocationDatabaseService;
  DataBaseStartTimeService _dataBaseStartTimeService;

  MapViewModel(
      this._mapLocationDatabaseService, this._dataBaseStartTimeService);

  CameraPosition? _initialLocation;
  LocationDto? _locationDto;
  double _palaceDistance = 0;
  bool _isRecordingStarted = false;

  bool _isMapCleared = true;
  bool get isMapCleared => this._isMapCleared;

  set isMapCleared(bool value) {
    this._isMapCleared = value;
    notifyListeners();
  }

  int _currentIndex = 0;
  CameraPosition? get initialLocation => this._initialLocation;

  set initialLocation(CameraPosition? value) {
    this._initialLocation = value;
    notifyListeners();
  }

  LocationDto? get locationDto => this._locationDto;

  set locationDto(LocationDto? value) {
    this._locationDto = value;
    notifyListeners();
  }

  double get palaceDistance => this._palaceDistance;

  set palaceDistance(double value) {
    this._palaceDistance = value;
    notifyListeners();
  }

  get isRecordingStarted => this._isRecordingStarted;

  set isRecordingStarted(value) {
    this._isRecordingStarted = value;
    notifyListeners();
  }

  get currentIndex => this._currentIndex;

  set currentIndex(value) {
    this._currentIndex = value;
    notifyListeners();
  }

  List<LocationDto> _locationDtos = [];
  List<LocationDto> get locationDtos => this._locationDtos;

  set locationDtos(List<LocationDto> value) {
    this._locationDtos = value;
    notifyListeners();
  }

  Marker? _marker;
  Marker? get marker => this._marker;
  set marker(Marker? value) {
    this._marker = value;
    notifyListeners();
  }

  Set<Polyline> _polyline = {};
  Set<Polyline> get polyline => this._polyline;
  set polyline(Set<Polyline> value) {
    this._polyline = value;
    notifyListeners();
  }

  List<LatLng> _pointLatLngList = [];
  List<LatLng> get pointLatLngList => this._pointLatLngList;
  set pointLatLngList(List<LatLng> value) {
    this._pointLatLngList = value;
    notifyListeners();
  }

  DateTime? _startTime;
  DateTime? get startTime => this._startTime;

  set startTime(DateTime? value) {
    this._startTime = value;
    notifyListeners();
  }

  DateTime? _endTime;
  DateTime? get endTime => this._endTime;

  set endTime(DateTime? value) {
    this._endTime = value;
    notifyListeners();
  }

  Future<void> addStartTime(DateTime startTime) async {
    await _dataBaseStartTimeService.insertStartTime(startTime);
  }

  Future<DateTime> getStartTime() async {
    return await _dataBaseStartTimeService.getStartTime();
  }

  Future<void> deleteStartTime() async {
    await _dataBaseStartTimeService.deleteStartTime();
  }

  Future<void> insertLocationDtotoDb(LocationDto locationDto) async {
    await _mapLocationDatabaseService.insertLocationDto(locationDto);
    this._locationDtos.add(locationDto);
    notifyListeners();
  }

  Future<void> addLocationDto(LocationDto locationDto) async {
    this._locationDtos.add(locationDto);
    notifyListeners();
  }

  Future<List<LocationDto>> getLocationDtoList() async {
    return await _mapLocationDatabaseService.getLocations();
  }

  Future<void> deleteLocationDtoList() async {
    await _mapLocationDatabaseService.deleteLocations();
  }
}
