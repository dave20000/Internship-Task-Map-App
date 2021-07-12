import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'package:app_map/model/view_model/map_model.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription? _locationSubscription;
  Location _locationTracker = Location();
  Marker? marker;
  GoogleMapController? _mapController;

  List<LatLng> pointLatLngList = [];
  String? timeTaken;
  DateTime? startTime;
  DateTime? endTime;

  void updateMarker(LocationData newLocalData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    pointLatLngList.add(latlng);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        rotation: newLocalData.heading!,
        draggable: false,
        zIndex: 2,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
      _polyline.add(Polyline(
        polylineId: PolylineId(
          latlng.toString(),
        ),
        visible: true,
        points: pointLatLngList,
        color: Colors.blue,
      ));
    });
  }

  void startLocationRecording(
      Function(LocationData, double) valueChanged) async {
    try {
      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  tilt: 0,
                  zoom: 18.00),
            ),
          );
          updateMarker(newLocalData);
          double distance = calculateDistance(
            pointLatLngList[pointLatLngList.length - 1],
            pointLatLngList[pointLatLngList.length - 2],
          );
          print(pointLatLngList.length);
          valueChanged(newLocalData, distance);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    super.dispose();
  }

  Set<Polyline> _polyline = {};
  List<Widget> widgets = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: mapViewModel.initialLocation,
              markers: Set.of((marker != null) ? [marker!] : []),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              polylines: _polyline,
              myLocationEnabled: true,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (mapViewModel.isRecordingStarted) {
                    marker = null;
                    // _locationSubscription = null;
                    _locationSubscription!.cancel();
                    _locationSubscription = null;
                    mapViewModel.isRecordingStarted = false;
                    endTime = DateTime.now();
                    timeTaken =
                        endTime!.difference(startTime!).inMinutes.toString();
                  } else {
                    mapViewModel.isRecordingStarted = true;
                    _polyline = {};
                    startTime = DateTime.now();
                    mapViewModel.palaceDistance = 0;
                    startLocationRecording((locationData, distance) {
                      mapViewModel.locationData = locationData;
                      print(distance);
                      mapViewModel.palaceDistance =
                          mapViewModel.palaceDistance + distance;
                      print(mapViewModel.palaceDistance);
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.amber),
                  child: !mapViewModel.isRecordingStarted
                      ? Icon(
                          Icons.play_arrow,
                          size: 30,
                        )
                      : Icon(
                          Icons.pause,
                          size: 30,
                        ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  double _coordinateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double calculateDistance(LatLng latLng1, LatLng latLng2) {
    double totalDistance = 0.0;
    totalDistance += _coordinateDistance(
      latLng1.latitude,
      latLng1.longitude,
      latLng2.latitude,
      latLng2.longitude,
    );
    print(totalDistance);
    return totalDistance;
  }
}
