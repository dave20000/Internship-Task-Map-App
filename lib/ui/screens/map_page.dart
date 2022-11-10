import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app_map/model/map_data.dart';
import 'package:app_map/model/view_model/map_model.dart';
import 'package:app_map/model/view_model/previous_tracks_model.dart';
import 'package:app_map/services/app_constants.dart';
import 'package:app_map/services/location_permission_helper.dart';
import 'package:app_map/ui/screens/details_page.dart';
import 'package:app_map/ui/widgets/base_widget.dart';
import 'package:app_map/ui/widgets/clear_map_button.dart';
import 'package:app_map/ui/widgets/expandel_content_bottom.dart';
import 'package:app_map/ui/widgets/map_drawer.dart';
import 'package:app_map/ui/widgets/persistent_header_bottom.dart';
import 'package:app_map/ui/widgets/record_button.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  ReceivePort port = ReceivePort();

  bool _myLocationEnabled = false;

  LocationPermissionHelper locationPermissionHelper =
      LocationPermissionHelper();
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  late AnimationController _appBarAnimationController;

  Future<void> _getCurrentPosition(
      MapViewModel mapViewModel, bool isMoveCamera) async {
    final hasLocationService =
        await locationPermissionHelper.handleLocationService();
    if (hasLocationService) {
      final hasPermission = await locationPermissionHelper.handlePermission();
      if (hasPermission) {
        setState(() {
          _myLocationEnabled = true;
        });
        Position position = await locationPermissionHelper.geolocatorPlatform
            .getCurrentPosition();
        mapViewModel.initialLocation = CameraPosition(
          bearing: 0,
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 14.0,
        );
        if (isMoveCamera) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              mapViewModel.initialLocation!,
            ),
          );
        }
      } else {
        setState(() {
          _myLocationEnabled = false;
        });
        print('Permission Denied');
        locationPermissionDialog(context);
      }
    } else {
      locationServiceStatusDialog(context);
    }
  }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream =
          locationPermissionHelper.geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen(
        (serviceStatus) {
          if (serviceStatus == ServiceStatus.enabled) {
            setState(() {
              _myLocationEnabled = true;
            });
            print('Service Enabled');
          } else {
            setState(() {
              _myLocationEnabled = false;
            });
            print('Service Disabled');
            locationServiceStatusDialog(context);
          }
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

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
      double distance =
          locationPermissionHelper.geolocatorPlatform.distanceBetween(
        mapViewModel.pointLatLngList[len - 1].latitude,
        mapViewModel.pointLatLngList[len - 1].longitude,
        mapViewModel.pointLatLngList[len - 2].latitude,
        mapViewModel.pointLatLngList[len - 2].longitude,
      );
      distance = distance / 1000;
      mapViewModel.locationDto = locationDto;
      mapViewModel.palaceDistance = mapViewModel.palaceDistance + distance;
    }
  }

  bool isDrawerOpen = false;
  @override
  Widget build(BuildContext context) {
    return BaseWidget<PreviousTrackViewModel>(
      onModelReady: (previousTrackViewModel) async {
        await previousTrackViewModel.getMapDatas();
      },
      builder: (context, previousTrackViewModel, child) {
        return BaseWidget<MapViewModel>(
          onModelReady: (mapViewModel) async {
            _toggleServiceStatusStream();
            print('Initializing...');
            await initStart(mapViewModel, previousTrackViewModel, context);
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
                  mapViewModel.locationDto = data as LocationDto;
                  await mapViewModel.insertLocationDtotoDb(locationDto);
                  updateData(mapViewModel, locationDto);
                }
              },
            );
          },
          onDispose: (mapViewModel) {
            _serviceStatusStreamSubscription?.cancel();
            _serviceStatusStreamSubscription = null;
          },
          builder: (context, mapViewModel, child) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: _appBarAnimationController,
                    ),
                    onPressed: () {
                      if (_scaffoldKey.currentState!.isDrawerOpen == false) {
                        _scaffoldKey.currentState!.openDrawer();
                        _appBarAnimationController.forward();
                        setState(() {
                          isDrawerOpen = true;
                        });
                      } else {
                        _scaffoldKey.currentState!.openEndDrawer();
                        _appBarAnimationController.reverse();
                        setState(() {
                          isDrawerOpen = false;
                        });
                      }
                    },
                  ),
                  title:
                      !isDrawerOpen ? Text("Map App") : Text("Past Trip Data"),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await deleteDialog(context, previousTrackViewModel);
                      },
                    )
                  ],
                ),
                body: Scaffold(
                  key: _scaffoldKey,
                  onDrawerChanged: (isOpened) {
                    setState(() {
                      isDrawerOpen = isOpened;
                    });
                    if (isOpened) {
                      _appBarAnimationController.forward();
                    } else {
                      _appBarAnimationController.reverse();
                    }
                  },
                  onEndDrawerChanged: (isOpened) {},
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
                            sideMapButtons(mapViewModel),
                            Positioned(
                              bottom: 130,
                              right: 8,
                              child: ClearMapButton(),
                            ),
                            Positioned(
                              bottom: 70,
                              right: 8,
                              child: RecordButton(),
                            ),
                          ],
                        ),
                        persistentHeader: PersistentHeaderBottom(),
                        expandableContent: ExpandableContentBottom(),
                      ),
                      DetailsPage(),
                    ],
                  ),
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

  deleteDialog(BuildContext context,
      PreviousTrackViewModel previousTrackViewModel) async {
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
                await previousTrackViewModel.deleteMapDatas();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> initStart(
      MapViewModel mapViewModel,
      PreviousTrackViewModel previousTrackViewModel,
      BuildContext context) async {
    await BackgroundLocator.initialize();
    mapViewModel.locationDtos = await mapViewModel.getLocationDtoList();
    if (mapViewModel.locationDtos.length != 0) {
      mapViewModel.startTime = await mapViewModel.getStartTime();
      mapViewModel.locationDtos.forEach(
        (element) {
          updateData(mapViewModel, element);
        },
      );
      bool isServiceEnabled =
          await locationPermissionHelper.handleLocationService();
      if (isServiceEnabled) {
        bool isPermissionEnabled =
            await locationPermissionHelper.handlePermission();
        if (isPermissionEnabled) {
          _getCurrentPosition(mapViewModel, false);
          mapViewModel.isRecordingStarted = true;
        } else {
          await stopRecording(mapViewModel, previousTrackViewModel);
          locationPermissionDialog(context);
        }
        _getCurrentPosition(mapViewModel, false);
        mapViewModel.isRecordingStarted = true;
      } else {
        await stopRecording(mapViewModel, previousTrackViewModel);
        locationServiceStatusDialog(context);
      }
    } else {
      _getCurrentPosition(mapViewModel, true);
      mapViewModel.isRecordingStarted = false;
    }
  }

  Future<dynamic> locationPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Permission not given"),
          content: Text("Please give location permission before procedding"),
          actions: [
            TextButton(
              child: Text("Open permission setting"),
              onPressed: () async {
                locationPermissionHelper.openAppSettings();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> locationServiceStatusDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Location Service not enabled"),
          content:
              Text("Please Enable location service from setting to continue"),
          actions: [
            TextButton(
              child: Text("Open location setting"),
              onPressed: () async {
                locationPermissionHelper.openLocationSettings();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> stopRecording(MapViewModel mapViewModel,
      PreviousTrackViewModel previousTrackViewModel) async {
    mapViewModel.isRecordingStarted = false;
    mapViewModel.isMapCleared = false;
    await onStop();
    await mapViewModel.deleteLocationDtoList();
    mapViewModel.locationDtos = [];
    await mapViewModel.deleteStartTime();
    mapViewModel.endTime = DateTime.now();
    await previousTrackViewModel.insertMapData(
      MapData(
        totalDistance: mapViewModel.palaceDistance,
        startTime: mapViewModel.startTime!,
        endTime: mapViewModel.endTime!,
        pointLatLngList: mapViewModel.pointLatLngList,
      ),
    );
  }

  Future<void> onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final _isRunning = await BackgroundLocator.isServiceRunning();
    print(_isRunning.toString());
  }

  Padding sideMapButtons(MapViewModel mapViewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _mapController!.animateCamera(CameraUpdate.zoomOut());
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blueGrey.shade300,
                ),
                child: Icon(
                  Icons.remove,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                _mapController!.animateCamera(CameraUpdate.zoomIn());
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blueGrey.shade300,
                ),
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                _getCurrentPosition(mapViewModel, true);
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
          ],
        ),
      ),
    );
  }
}
