import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapViewModel extends ChangeNotifier {
  CameraPosition _initialLocation = CameraPosition(
    target: LatLng(
      52.1885,
      5.34271,
    ),
    zoom: 11.5,
  );
  LocationData? _locationData;
  double _palaceDistance = 0;
  bool _isRecordingStarted = false;
  int _currentIndex = 0;
  CameraPosition get initialLocation => this._initialLocation;

  set initialLocation(CameraPosition value) {
    this._initialLocation = value;
    notifyListeners();
  }

  get locationData => this._locationData;

  set locationData(value) {
    this._locationData = value;
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
}
