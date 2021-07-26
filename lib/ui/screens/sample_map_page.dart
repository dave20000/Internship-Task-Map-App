// import 'dart:async';
// import 'dart:isolate';
// import 'dart:math';
// import 'dart:ui';

// import 'package:background_locator/background_locator.dart';
// import 'package:background_locator/location_dto.dart';
// import 'package:background_locator/settings/android_settings.dart';
// import 'package:background_locator/settings/ios_settings.dart';
// import 'package:background_locator/settings/locator_settings.dart';
// import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
// import 'package:permission_handler/permission_handler.dart' as ph;
// import 'package:provider/provider.dart';

// import 'package:app_map/model/map_data.dart';
// import 'package:app_map/model/view_model/map_model.dart';
// import 'package:app_map/model/view_model/previous_tracks_model.dart';
// import 'package:app_map/services/app_constants.dart';
// import 'package:app_map/services/databases/database_service.dart';
// import 'package:app_map/services/databases/database_start_time.dart';
// import 'package:app_map/services/location_callback_handler.dart';
// import 'package:app_map/ui/widgets/base_widget.dart';
// import 'package:app_map/ui/widgets/map_drawer.dart';

// class SampleMapPage extends StatefulWidget {
//   @override
//   _SampleMapPageState createState() => _SampleMapPageState();
// }

// class _SampleMapPageState extends State<SampleMapPage> {
//   Marker? marker;
//   GoogleMapController? _mapController;

//   void updateMarker(LocationDto locationDto, List<LatLng> pointsL) {
//     LatLng latlng = LatLng(locationDto.latitude, locationDto.longitude);
//     this.setState(() {
//       marker = Marker(
//         markerId: MarkerId("home"),
//         position: latlng,
//         rotation: locationDto.heading,
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
//         points: pointsL,
//         color: Colors.blue,
//       ));
//     });
//   }

//   void startLocationRecording() async {
//     var permissionStatus = await ph.Permission.locationAlways.request();
//     if (permissionStatus == ph.PermissionStatus.granted) {
//       Map<String, dynamic> data = {'countInit': 1};
//       await BackgroundLocator.registerLocationUpdate(
//         LocationCallbackHandler.callback,
//         initCallback: LocationCallbackHandler.initCallback,
//         initDataCallback: data,
//         disposeCallback: LocationCallbackHandler.disposeCallback,
//         autoStop: false,
//         iosSettings: IOSSettings(
//             accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
//         androidSettings: AndroidSettings(
//           accuracy: LocationAccuracy.NAVIGATION,
//           interval: 5,
//           distanceFilter: 0,
//           androidNotificationSettings: AndroidNotificationSettings(
//             notificationChannelName: 'Location tracking',
//             notificationTitle: 'Start Location Tracking',
//             notificationMsg: 'Track location in background',
//             notificationBigMsg:
//                 'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
//             notificationIcon: '',
//             notificationIconColor: Colors.grey,
//             notificationTapCallback:
//                 LocationCallbackHandler.notificationCallback,
//           ),
//         ),
//       );
//     } else {
//       print("Permission not granted ${permissionStatus.toString()}");
//     }
//   }

//   Future<void> onStop() async {
//     await BackgroundLocator.unRegisterLocationUpdate();
//     final _isRunning = await BackgroundLocator.isServiceRunning();
//     await mapLocationDatabaseService.deleteLocations();
//     print(_isRunning.toString());
//   }

//   Set<Polyline> _polyline = {};

//   MapLocationDatabaseService mapLocationDatabaseService =
//       MapLocationDatabaseService();
//   DataBaseStartTimeService dataBaseStartTimeService =
//       DataBaseStartTimeService();
//   ReceivePort port = ReceivePort();

//   @override
//   Widget build(BuildContext context) {
//     return BaseWidget<PreviousTrackViewModel>(
//       builder: (context, previousTrackViewModel, child) {
//         return BaseWidget<MapViewModel>(
//           onModelReady: (mapViewModel) async {
//             print('Initializing...');
//             await BackgroundLocator.initialize();
//             List<LocationDto> locationDtoList =
//                 await mapLocationDatabaseService.getLocations();
//             locationDtoList.forEach((element) {
//               print(element.toString());
//             });
//             mapViewModel.locationDtos = locationDtoList;
//             print(mapViewModel.locationDtos.length);
//             if (mapViewModel.locationDtos.length != 0) {
//               mapViewModel.locationDtos.forEach(
//                 (element) {
//                   LatLng latlng = LatLng(
//                     element.latitude,
//                     element.longitude,
//                   );
//                   _mapController!.animateCamera(
//                     CameraUpdate.newCameraPosition(
//                       new CameraPosition(
//                         bearing: 192.8334901395799,
//                         target: latlng,
//                         tilt: 0,
//                         zoom: 18.00,
//                       ),
//                     ),
//                   );
//                   mapViewModel.pointLatLngList.add(latlng);
//                   updateMarker(element, mapViewModel.pointLatLngList);
//                   if (mapViewModel.pointLatLngList.length > 1) {
//                     double distance = calculateDistance(
//                       mapViewModel.pointLatLngList[
//                           mapViewModel.pointLatLngList.length - 1],
//                       mapViewModel.pointLatLngList[
//                           mapViewModel.pointLatLngList.length - 2],
//                     );
//                     mapViewModel.locationDto = element;
//                     mapViewModel.palaceDistance =
//                         mapViewModel.palaceDistance + distance;
//                   } else {}
//                 },
//               );
//               // mapViewModel.startTime =
//               //     await mapLocationDatabaseService.getStartTime();
//               mapViewModel.startTime =
//                   await dataBaseStartTimeService.getStartTime();
//               mapViewModel.isRecordingStarted = true;
//             }
//             print('Initialization done');
//             mapViewModel.isRecordingStarted =
//                 await BackgroundLocator.isServiceRunning();
//             print('Running ${mapViewModel.isRecordingStarted.toString()}');

//             loc.LocationData location = await loc.Location().getLocation();
//             mapViewModel.initialLocation = CameraPosition(
//               target: LatLng(
//                 location.latitude!,
//                 location.longitude!,
//               ),
//               zoom: 11.5,
//             );

//             if (IsolateNameServer.lookupPortByName(AppConstants.isolateName) !=
//                 null) {
//               IsolateNameServer.removePortNameMapping(AppConstants.isolateName);
//             }
//             IsolateNameServer.registerPortWithName(
//                 port.sendPort, AppConstants.isolateName);
//             port.listen(
//               (dynamic data) async {
//                 if (data != null) {
//                   LocationDto locationDto = data;
//                   print(
//                     "main hu",
//                   );
//                   mapViewModel.locationDto = locationDto;
//                   mapViewModel.addLocationDtos(locationDto);
//                   LatLng latlng =
//                       LatLng(locationDto.latitude, locationDto.longitude);
//                   mapViewModel.pointLatLngList.add(latlng);
//                   _mapController!.animateCamera(
//                     CameraUpdate.newCameraPosition(
//                       new CameraPosition(
//                         bearing: 192.8334901395799,
//                         target: latlng,
//                         tilt: 0,
//                         zoom: 18.00,
//                       ),
//                     ),
//                   );
//                   // if (mapViewModel.locationDtos.length == 1) {
//                   //   previousTrackViewModel.startTime =

//                   // }
//                   print(mapViewModel.locationDto!.time.toString());
//                   updateMarker(locationDto, mapViewModel.pointLatLngList);
//                   if (mapViewModel.pointLatLngList.length > 1) {
//                     double distance = calculateDistance(
//                       mapViewModel.pointLatLngList[
//                           mapViewModel.pointLatLngList.length - 1],
//                       mapViewModel.pointLatLngList[
//                           mapViewModel.pointLatLngList.length - 2],
//                     );
//                     mapViewModel.locationDto = locationDto;
//                     mapViewModel.palaceDistance =
//                         mapViewModel.palaceDistance + distance;
//                     print(mapViewModel.palaceDistance);
//                   } else {}
//                 }
//               },
//             );
//           },
//           builder: (context, mapViewModel, child) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text("Map App"),
//               ),
//               drawer: MapDrawer(
//                 mapData: previousTrackViewModel.mapDatas,
//               ),
//               body: ExpandableBottomSheet(
//                 background: Stack(
//                   children: [
//                     GoogleMap(
//                       zoomControlsEnabled: false,
//                       mapType: MapType.normal,
//                       initialCameraPosition: mapViewModel.initialLocation,
//                       markers: Set.of((marker != null) ? [marker!] : []),
//                       onMapCreated: (GoogleMapController controller) {
//                         _mapController = controller;
//                       },
//                       polylines: _polyline,
//                       myLocationEnabled: true,
//                     ),
//                     !mapViewModel.isMapCleared
//                         ? Positioned(
//                             top: 20,
//                             left: 20,
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   marker = null;
//                                   _polyline = {};
//                                   mapViewModel.palaceDistance = 0;
//                                   mapViewModel.locationDto = null;
//                                   mapViewModel.pointLatLngList = [];
//                                 });
//                                 mapViewModel.isMapCleared = true;
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.amber),
//                                 child: Icon(
//                                   Icons.clear,
//                                   size: 30,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : SizedBox(),
//                     Positioned(
//                       bottom: 70,
//                       right: 15,
//                       child: GestureDetector(
//                         onTap: () async {
//                           if (mapViewModel.isMapCleared) {
//                             if (mapViewModel.isRecordingStarted) {
//                               mapViewModel.isRecordingStarted = false;
//                               mapViewModel.isMapCleared = false;
//                               await onStop();
//                               mapViewModel.locationDtos = [];

//                               dataBaseStartTimeService.deleteStartTime();

//                               mapViewModel.endTime = DateTime.now();

//                               previousTrackViewModel.insertMapData(MapData(
//                                 totalDistance: mapViewModel.palaceDistance,
//                                 startTime: mapViewModel.startTime!,
//                                 endTime: mapViewModel.endTime!,
//                                 pointLatLngList: mapViewModel.pointLatLngList,
//                               ));
//                               print(previousTrackViewModel
//                                   .mapDatas[
//                                       previousTrackViewModel.mapDatas.length -
//                                           1]
//                                   .totalDistance);
//                             } else {
//                               mapViewModel.isRecordingStarted = true;
//                               mapViewModel.palaceDistance = 0;
//                               mapViewModel.startTime = DateTime.now();
//                               // mapLocationDatabaseService
//                               //     .insertStartTime(mapViewModel.startTime!);
//                               dataBaseStartTimeService
//                                   .insertStartTime(mapViewModel.startTime!);
//                               startLocationRecording();
//                             }
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text("Clear map first"),
//                               ),
//                             );
//                           }
//                         },
//                         child: Container(
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                               shape: BoxShape.circle, color: Colors.amber),
//                           child: !mapViewModel.isRecordingStarted
//                               ? Icon(
//                                   Icons.play_arrow,
//                                   size: 30,
//                                 )
//                               : Icon(
//                                   Icons.pause,
//                                   size: 30,
//                                 ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 persistentHeader: Container(
//                     height: 60,
//                     color: Colors.blueGrey.shade100,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           "Distance Covered: " +
//                               mapViewModel.palaceDistance.toString(),
//                         ),
//                         mapViewModel.locationDto != null
//                             ? Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   Text("Latitiude: " +
//                                       mapViewModel.locationDto!.latitude
//                                           .toString()),
//                                   Text("Longitude: --" +
//                                       mapViewModel.locationDto!.longitude
//                                           .toString()),
//                                 ],
//                               )
//                             : Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   Text("Latitiude: --"),
//                                   Text("Longitude: --"),
//                                 ],
//                               ),
//                       ],
//                     )),
//                 expandableContent: Container(
//                   height: 40,
//                   color: Colors.blueGrey.shade100,
//                   child: mapViewModel.locationDto != null
//                       ? Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Text("Accuracy: " +
//                                 mapViewModel.locationDto!.accuracy.toString()),
//                             Text("Speed: " +
//                                 mapViewModel.locationDto!.speed.toString()),
//                           ],
//                         )
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Text("Accuracy: --"),
//                             Text("Speed --"),
//                           ],
//                         ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   double _coordinateDistance(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     var p = 0.017453292519943295;
//     var c = cos;
//     var a = 0.5 -
//         c((lat2 - lat1) * p) / 2 +
//         c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a));
//   }

//   double calculateDistance(LatLng latLng1, LatLng latLng2) {
//     double totalDistance = 0.0;
//     totalDistance += _coordinateDistance(
//       latLng1.latitude,
//       latLng1.longitude,
//       latLng2.latitude,
//       latLng2.longitude,
//     );
//     print(totalDistance);
//     return totalDistance;
//   }
// }
