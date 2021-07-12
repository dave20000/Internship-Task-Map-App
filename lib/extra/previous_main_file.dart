import 'dart:math';

import 'direction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  //LatLng _center = const LatLng(13.0827, 80.2707);
  LatLng? _center;

  CameraPosition? _cameraPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void getCurrentPosition() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _center = LatLng(position.latitude, position.longitude);
    print(_center!.latitude);
    print(_center!.longitude);
    setState(() {
      _cameraPosition = CameraPosition(
        zoom: 11.5,
        target: _center!,
      );
    });
    _getAddress(_center!, true);
  }

  Marker? _originMarker;
  Marker? _destinationMarker;

  late TextEditingController originEditingController;
  late TextEditingController destinationEditingController;
  late FocusNode originFocusNode;
  late FocusNode destinationFocusNode;
  String currentAddress = '';

  LatLng? originLatlan;
  LatLng? destinationLatlan;
  Map<PolylineId, Polyline> polylines = {};

  _getAddress(LatLng position, bool isOrigin) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark currentPlace = placemarks[0];
      setState(() {
        currentAddress =
            "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.postalCode}, ${currentPlace.country}";
        if (isOrigin) {
          originEditingController.text = currentAddress;
        } else {
          destinationEditingController.text = currentAddress;
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getCurrentPosition();
    originEditingController = TextEditingController();
    destinationEditingController = TextEditingController();
    destinationFocusNode = FocusNode();
    originFocusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Map Navigation"),
        ),
        body: _center != null
            ? Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: _cameraPosition!,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    onLongPress: _setMarker,
                    markers: {
                      if (_originMarker != null) _originMarker!,
                      if (_destinationMarker != null) _destinationMarker!
                    },
                    onTap: (LatLng latLng) {
                      originFocusNode.unfocus();
                      destinationFocusNode.unfocus();
                    },
                    polylines: Set<Polyline>.of(polylines.values),
                  ),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    left: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Distance",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _placeDistance == null ? false : true,
                              child: Text(
                                '$_placeDistance km',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: originEditingController,
                                focusNode: originFocusNode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  prefixIcon: Icon(Icons.trip_origin),
                                  labelText: "Origin",
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: TextField(
                                controller: destinationEditingController,
                                focusNode: destinationFocusNode,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  prefixIcon: Icon(Icons.add_to_drive_sharp),
                                  labelText: "Destination",
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (originEditingController.text.isNotEmpty &&
                                      destinationEditingController
                                          .text.isNotEmpty) {
                                    originFocusNode.unfocus();
                                    destinationFocusNode.unfocus();
                                    // print(originLatlan!.longitude.toString() +
                                    //     " " +
                                    //     destinationLatlan!.longitude
                                    //         .toString());
                                    await _createPolylineAndCalculateDistance();
                                  }
                                },
                                child: Text(
                                  "Calculate Distance",
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.greenAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                _cameraPosition!,
              ),
            );
          },
          child: Icon(
            Icons.my_location,
          ),
        ),
      ),
    );
  }

  void _setMarker(LatLng position) {
    if (_originMarker == null ||
        (_originMarker != null && _destinationMarker != null)) {
      _getAddress(position, true);
      destinationEditingController.text = "";
      _placeDistance = null;
      setState(() {
        originLatlan = position;
        _originMarker = Marker(
          markerId: MarkerId('origin'),
          infoWindow: InfoWindow(title: originEditingController.text),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: position,
        );
        _destinationMarker = null;
      });
    } else {
      setState(() {
        destinationLatlan = position;
        _getAddress(position, false);
        _destinationMarker = Marker(
          markerId: MarkerId('destination'),
          infoWindow: InfoWindow(title: destinationEditingController.text),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: position,
        );
      });
    }
  }

  Future<void> _createPolylineAndCalculateDistance() async {
    try {
      var polyLinePoints = PolylinePoints();
      PolylineResult polylineResult =
          await polyLinePoints.getRouteBetweenCoordinates(
        "AIzaSyAG-g1PPSUn_eExww0wuUq3I9gx9hInn4A",
        PointLatLng(originLatlan!.latitude, originLatlan!.longitude),
        PointLatLng(destinationLatlan!.latitude, destinationLatlan!.longitude),
      );
      print(polylineResult.status);
      print(polylineResult.errorMessage);
      // print(originLatlan!.latitude.toString() +
      //     " " +
      //     destinationLatlan!.latitude.toString());
      var directions = await DirectionsService().getDirections(
          origin: originLatlan!, destination: destinationLatlan!);
      List<LatLng> polylineCoordinates = [];
      if (polylineResult.points.isNotEmpty) {
        polylineResult.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );
      setState(() {
        polylines[id] = polyline;
      });

      //distance
      double totalDistance = 0.0;
      // for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      //   totalDistance += _coordinateDistance(
      //     polylineCoordinates[i].latitude,
      //     polylineCoordinates[i].longitude,
      //     polylineCoordinates[i + 1].latitude,
      //     polylineCoordinates[i + 1].longitude,
      //   );
      // }

      totalDistance += _coordinateDistance(
        originLatlan!.latitude,
        originLatlan!.longitude,
        destinationLatlan!.latitude,
        destinationLatlan!.longitude,
      );

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });
    } catch (e) {
      print(e.toString());
    }
  }

  String? _placeDistance;

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}



// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Maps',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   StreamSubscription? _locationSubscription;
//   Location _locationTracker = Location();
//   Marker? marker;
//   GoogleMapController? _mapController;

//   CameraPosition? initialLocation;

//   List<LatLng> pointLatLngList = [];

//   void getInitialLocation() async {
//     LocationData location = await _locationTracker.getLocation();
//     setState(() {
//       initialLocation = CameraPosition(
//         target: LatLng(
//           location.latitude!,
//           location.longitude!,
//         ),
//         zoom: 11.5,
//       );
//     });
//   }

//   void updateMarker(LocationData newLocalData) {
//     LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
//     pointLatLngList.add(latlng);
//     this.setState(() {
//       marker = Marker(
//         markerId: MarkerId("home"),
//         position: latlng,
//         rotation: newLocalData.heading!,
//         draggable: false,
//         zIndex: 2,
//         icon: BitmapDescriptor.defaultMarkerWithHue(
//           BitmapDescriptor.hueGreen,
//         ),
//       );
//       _polyline.add(Polyline(
//         polylineId: PolylineId(
//           latlng.toString(),
//         ),
//         visible: true,
//         //latlng is List<LatLng>
//         points: pointLatLngList,
//         color: Colors.blue,
//       ));
//     });
//   }

//   LocationData? _locationData;

//   void startLocationRecording() async {
//     try {
//       // LocationData location = await _locationTracker.getLocation();
//       // setState(() {
//       //   _locationData = location;
//       // });
//       // updateMarker(location);

//       if (_locationSubscription != null) {
//         _locationSubscription!.cancel();
//       }

//       _locationSubscription =
//           _locationTracker.onLocationChanged.listen((newLocalData) {
//         setState(() {
//           _locationData = newLocalData;
//         });
//         if (_mapController != null) {
//           _mapController!.animateCamera(
//             CameraUpdate.newCameraPosition(
//               new CameraPosition(
//                   bearing: 192.8334901395799,
//                   target:
//                       LatLng(newLocalData.latitude!, newLocalData.longitude!),
//                   tilt: 0,
//                   zoom: 18.00),
//             ),
//           );
//           updateMarker(newLocalData);
//         }
//       });
//     } on PlatformException catch (e) {
//       if (e.code == 'PERMISSION_DENIED') {
//         debugPrint("Permission Denied");
//       }
//     }
//   }

//   @override
//   void initState() {
//     getInitialLocation();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     if (_locationSubscription != null) {
//       _locationSubscription!.cancel();
//     }
//     super.dispose();
//   }

//   final Set<Polyline> _polyline = {};

//   bool isRecordingStarted = false;

//   List<Widget> widgets = [];

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         bottomNavigationBar: BottomNavigationBar(
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.map),
//               label: "Map",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.details),
//               label: "Details",
//             ),
//           ],
//         ),
//         body: initialLocation != null
//             ?
//             //  Column(
//             //     children: [
//             //       Expanded(
//             //         child: GoogleMap(
//             //           zoomControlsEnabled: false,
//             //           mapType: MapType.normal,
//             //           initialCameraPosition: initialLocation!,
//             //           markers: Set.of((marker != null) ? [marker!] : []),
//             //           onMapCreated: (GoogleMapController controller) {
//             //             _mapController = controller;
//             //           },
//             //           polylines: _polyline,
//             //           myLocationEnabled: true,
//             //         ),
//             //       ),
//             //       isRecordingStarted
//             //           ? Container(
//             //               padding: EdgeInsets.all(10),
//             //               child: _locationData != null
//             //                   ? Row(
//             //                       mainAxisAlignment:
//             //                           MainAxisAlignment.spaceBetween,
//             //                       children: [
//             //                         Text(
//             //                           "Latitude: " +
//             //                               _locationData!.latitude.toString(),
//             //                         ),
//             //                         Text(
//             //                           "Longitude: " +
//             //                               _locationData!.longitude.toString(),
//             //                         ),
//             //                         Text(
//             //                           "accuracy: " +
//             //                               _locationData!.accuracy.toString(),
//             //                         ),
//             //                       ],
//             //                     )
//             //                   : SizedBox(),
//             //             )
//             //           : SizedBox(),
//             //       isRecordingStarted
//             //           ? Container(
//             //               padding: EdgeInsets.all(10),
//             //               child: _locationData != null
//             //                   ? Row(
//             //                       mainAxisAlignment:
//             //                           MainAxisAlignment.spaceBetween,
//             //                       children: [
//             //                         Text(
//             //                           "Speed: " +
//             //                               _locationData!.speed!
//             //                                   .toStringAsPrecision(8),
//             //                         ),
//             //                         Text(
//             //                           "Satellite Number: " +
//             //                               _locationData!.satelliteNumber
//             //                                   .toString(),
//             //                         ),
//             //                         Text(
//             //                           "Time: " + _locationData!.time.toString(),
//             //                         ),
//             //                       ],
//             //                     )
//             //                   : SizedBox(),
//             //             )
//             //           : SizedBox(),
//             //       isRecordingStarted
//             //           ? Container(
//             //               padding: EdgeInsets.all(10),
//             //               child: _locationData != null
//             //                   ? Text(
//             //                       "Total Distance Covered: " +
//             //                           _locationData!.speed!
//             //                               .toStringAsPrecision(8),
//             //                     )
//             //                   : SizedBox(),
//             //             )
//             //           : SizedBox(),
//             //     ],
//             //   )
//             Expanded(
//                 child: GoogleMap(
//                   zoomControlsEnabled: false,
//                   mapType: MapType.normal,
//                   initialCameraPosition: initialLocation!,
//                   markers: Set.of((marker != null) ? [marker!] : []),
//                   onMapCreated: (GoogleMapController controller) {
//                     _mapController = controller;
//                   },
//                   polylines: _polyline,
//                   myLocationEnabled: true,
//                 ),
//               )
//             : SizedBox(),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             if (isRecordingStarted) {
//               setState(() {
//                 marker = null;
//                 _locationSubscription = null;
//                 isRecordingStarted = false;
//               });
//             } else {
//               setState(() {
//                 isRecordingStarted = true;
//               });
//               startLocationRecording();
//             }
//           },
//           child: !isRecordingStarted
//               ? Icon(
//                   Icons.one_k_plus,
//                 )
//               : Icon(
//                   Icons.two_k_plus,
//                 ),
//         ),
//       ),
//     );
//   }

//   String? _placeDistance;

//   double _coordinateDistance(lat1, lon1, lat2, lon2) {
//     var p = 0.017453292519943295;
//     var c = cos;
//     var a = 0.5 -
//         c((lat2 - lat1) * p) / 2 +
//         c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a));
//   }

//   void calculateDistance() {
//     double totalDistance = 0.0;
//     for (int i = 0; i < pointLatLngList.length - 1; i++) {
//       totalDistance += _coordinateDistance(
//         pointLatLngList[i].latitude,
//         pointLatLngList[i].longitude,
//         pointLatLngList[i + 1].latitude,
//         pointLatLngList[i + 1].longitude,
//       );
//     }
//     setState(() {
//       _placeDistance = totalDistance.toStringAsFixed(2);
//       print('DISTANCE: $_placeDistance km');
//     });
//   }
// }
