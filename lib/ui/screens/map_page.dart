import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:app_map/model/view_model/map_model.dart';
import 'package:app_map/model/view_model/previous_tracks_model.dart';
import 'package:app_map/services/app_constants.dart';
import 'package:app_map/ui/screens/result_page.dart';
import 'package:app_map/ui/widgets/base_widget.dart';
import 'package:app_map/ui/widgets/clear_map_button.dart';
import 'package:app_map/ui/widgets/expandel_content_bottom.dart';
import 'package:app_map/ui/widgets/map_drawer.dart';
import 'package:app_map/ui/widgets/persistent_header_bottom.dart';
import 'package:app_map/ui/widgets/record_button.dart';

class MapPage extends StatefulWidget {
  static String id = 'MapPage';
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  ReceivePort port = ReceivePort();
  Location location = Location();

  bool _myLocationEnabled = false;
  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkServiceStatus();
      _checkPermissionStatus();
    }
  }

  Future<void> _checkServiceStatus() async {
    var _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled) {
      print('Service Enabled');
    } else {
      print('Service not Enabled');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Location Service not enabled"),
            content: Text("Please Enable location service"),
            actions: [
              TextButton(
                child: Text("Okay"),
                onPressed: () async {
                  _serviceEnabled = await location.requestService();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _checkPermissionStatus() async {
    var status = await location.hasPermission();
    if (status == PermissionStatus.granted) {
      setState(() {
        _myLocationEnabled = true;
      });
      print('Permission granted');
    } else if (status == PermissionStatus.denied) {
      setState(() {
        _myLocationEnabled = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Permission not given"),
            content: Text("Please give location permission before procedding"),
            actions: [
              TextButton(
                child: Text("Okay"),
                onPressed: () async {
                  status = await location.requestPermission();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      //_checkPermission();
    } else if (status == PermissionStatus.deniedForever) {
      print('Take the user to the settings page.');
    }
  }

  void updateMarker(MapViewModel mapViewModel, LocationDto locationDto,
      List<LatLng> pointsL) {
    LatLng latlng = LatLng(locationDto.latitude, locationDto.longitude);
    mapViewModel.marker = Marker(
      markerId: MarkerId("home"),
      position: latlng,
      rotation: locationDto.heading,
      draggable: false,
      zIndex: 2,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
    );
    mapViewModel.polyline.add(
      Polyline(
        polylineId: PolylineId(
          latlng.toString(),
        ),
        visible: true,
        points: pointsL,
        color: Colors.blue,
      ),
    );
  }

  void updateData(MapViewModel mapViewModel, LocationDto locationDto) {
    LatLng latlng = LatLng(
      locationDto.latitude,
      locationDto.longitude,
    );
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        new CameraPosition(
          bearing: 192.8334901395799,
          target: latlng,
          tilt: 0,
          zoom: 18.00,
        ),
      ),
    );
    mapViewModel.pointLatLngList.add(latlng);
    updateMarker(mapViewModel, locationDto, mapViewModel.pointLatLngList);
    int len = mapViewModel.pointLatLngList.length;
    if (len > 1) {
      double distance = calculateDistance(
        mapViewModel.pointLatLngList[len - 1],
        mapViewModel.pointLatLngList[len - 2],
      );
      mapViewModel.locationDto = locationDto;
      mapViewModel.palaceDistance = mapViewModel.palaceDistance + distance;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<PreviousTrackViewModel>(
      onModelReady: (previousTrackViewModel) async {
        await previousTrackViewModel.getMapDatas();
      },
      builder: (context, previousTrackViewModel, child) {
        return BaseWidget<MapViewModel>(
          onModelReady: (mapViewModel) async {
            //await _checkGps();
            print('Initializing...');
            await BackgroundLocator.initialize();
            List<LocationDto> locationDtoList =
                await mapViewModel.getLocationDtoList();
            // locationDtoList.forEach((element) {
            //   print(element.toString());
            // });
            mapViewModel.locationDtos = locationDtoList;
            if (mapViewModel.locationDtos.length != 0) {
              mapViewModel.locationDtos.forEach(
                (element) {
                  updateData(mapViewModel, element);
                },
              );
              mapViewModel.startTime = await mapViewModel.getStartTime();
              mapViewModel.isRecordingStarted = true;
            } else {
              LocationData currentLocation = await location.getLocation();
              mapViewModel.initialLocation = CameraPosition(
                bearing: 0,
                target: LatLng(
                  currentLocation.latitude!,
                  currentLocation.longitude!,
                ),
                zoom: 17.0,
              );
              mapViewModel.isRecordingStarted = false;
            }
            print('Initialization done');
            var serviceRunning = await BackgroundLocator.isServiceRunning();
            print('Running ${serviceRunning.toString()}');

            if (IsolateNameServer.lookupPortByName(AppConstants.isolateName) !=
                null) {
              IsolateNameServer.removePortNameMapping(AppConstants.isolateName);
            }
            IsolateNameServer.registerPortWithName(
              port.sendPort,
              AppConstants.isolateName,
            );
            port.listen(
              (dynamic data) async {
                if (data != null) {
                  LocationDto locationDto = data;
                  mapViewModel.locationDto = locationDto;
                  await mapViewModel.insertLocationDtotoDb(locationDto);
                  updateData(mapViewModel, locationDto);
                }
              },
            );
          },
          builder: (context, mapViewModel, child) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Map App"),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text(
                                "Are you sure you want to delete all track data?",
                              ),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text("Continue"),
                                  onPressed: () async {
                                    await previousTrackViewModel
                                        .deleteMapDatas();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
                drawer: MapDrawer(),
                body: IndexedStack(
                  index: mapViewModel.currentIndex,
                  children: [
                    ExpandableBottomSheet(
                      background: Stack(
                        children: [
                          GoogleMap(
                            zoomControlsEnabled: false,
                            mapType: MapType.normal,
                            initialCameraPosition:
                                mapViewModel.initialLocation ??
                                    CameraPosition(
                                      target: LatLng(
                                        52.1885,
                                        5.34271,
                                      ),
                                      zoom: 11.5,
                                    ),
                            markers: Set.of((mapViewModel.marker != null)
                                ? [mapViewModel.marker!]
                                : []),
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            polylines: mapViewModel.polyline,
                            myLocationEnabled: _myLocationEnabled,
                            myLocationButtonEnabled: false,
                          ),
                          Positioned(
                            bottom: 130,
                            right: 15,
                            child: ClearMapButton(),
                          ),
                          Positioned(
                            bottom: 70,
                            right: 15,
                            child: RecordButton(),
                          ),
                          Positioned(
                            bottom: MediaQuery.of(context).size.height / 3.0,
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                _currentLocation(mapViewModel);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueGrey.shade300,
                                ),
                                child: Icon(
                                  Icons.location_searching,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      persistentHeader: PersistentHeaderBottom(),
                      expandableContent: ExpandableContentBottom(),
                    ),
                    ResultPage(),
                  ],
                ),
                bottomNavigationBar: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.blueGrey,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: mapViewModel.currentIndex,
                    unselectedItemColor: Colors.white70,
                    selectedItemColor: Colors.white,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.map),
                        label: "Map",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.details),
                        label: "Details",
                      ),
                    ],
                    onTap: (index) {
                      mapViewModel.currentIndex = index;
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _currentLocation(MapViewModel mapViewModel) async {
    bool permissionGiven = await checkGps();
    if (permissionGiven) {
      LocationData? currentLocation;
      try {
        currentLocation = await location.getLocation();
      } on Exception {
        currentLocation = null;
      }
      if (currentLocation != null) {
        mapViewModel.initialLocation = CameraPosition(
          bearing: 0,
          target: LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          ),
          zoom: 17.0,
        );
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            mapViewModel.initialLocation!,
          ),
        );
      } else {
        print("location not found error");
      }
    } else {
      print("Permission not get error");
    }
  }

  Future<bool> checkGps() async {
    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    if (_permissionGranted != PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  double _coordinateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double calculateDistance(LatLng latLng1, LatLng latLng2) {
    double distance = 0.0;
    distance += _coordinateDistance(
      latLng1.latitude,
      latLng1.longitude,
      latLng2.latitude,
      latLng2.longitude,
    );
    print(distance);
    return distance;
  }
}
