import 'dart:async';
import 'dart:math';

import 'package:app_map/model/map_data.dart';
import 'package:app_map/model/view_model/previous_tracks_model.dart';
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
          if (pointLatLngList.length > 1) {
            double distance = calculateDistance(
              pointLatLngList[pointLatLngList.length - 1],
              pointLatLngList[pointLatLngList.length - 2],
            );
            print(pointLatLngList.length);
            valueChanged(newLocalData, distance);
          } else {
            valueChanged(newLocalData, 0);
          }
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
            !mapViewModel.isMapCleared
                ? Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          marker = null;
                          _polyline = {};
                          pointLatLngList = [];
                          mapViewModel.palaceDistance = 0;
                          mapViewModel.locationData = null;
                        });
                        mapViewModel.isMapCleared = true;
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.amber),
                        child: Icon(
                          Icons.clear,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            Positioned(
              bottom: 20,
              right: 20,
              child: Consumer<PreviousTrackViewModel>(
                  builder: (context, previousTrackViewModel, child) {
                return GestureDetector(
                  onTap: () {
                    if (mapViewModel.isMapCleared) {
                      if (mapViewModel.isRecordingStarted) {
                        setState(() {
                          _locationSubscription!.cancel();
                          _locationSubscription = null;
                          endTime = DateTime.now();
                          timeTaken = endTime!
                              .difference(startTime!)
                              .inMinutes
                              .toString();
                        });
                        mapViewModel.isRecordingStarted = false;
                        mapViewModel.isMapCleared = false;
                        previousTrackViewModel.addNewMapData(MapData(
                          totalDistance: mapViewModel.palaceDistance,
                          timeTaken: timeTaken!,
                          startTime: startTime!,
                          endTime: endTime!,
                          pointLatLngList: pointLatLngList,
                        ));
                        print(previousTrackViewModel
                            .mapDatas[
                                previousTrackViewModel.mapDatas.length - 1]
                            .totalDistance);
                      } else {
                        setState(() {
                          startTime = DateTime.now();
                        });
                        mapViewModel.isRecordingStarted = true;
                        mapViewModel.palaceDistance = 0;
                        startLocationRecording((locationData, distance) {
                          mapViewModel.locationData = locationData;
                          print(distance);
                          mapViewModel.palaceDistance =
                              mapViewModel.palaceDistance + distance;
                          print(mapViewModel.palaceDistance);
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Clear map first"),
                        ),
                      );
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
                );
              }),
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
