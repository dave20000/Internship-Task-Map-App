import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app_map/model/map_data.dart';

class MapPreviewScreen extends StatefulWidget {
  final MapData mapData;
  MapPreviewScreen({
    required this.mapData,
  });
  @override
  _MapPreviewScreenState createState() => _MapPreviewScreenState();
}

class _MapPreviewScreenState extends State<MapPreviewScreen> {
  GoogleMapController? _mapController;

  late CameraPosition initialLocation;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    initialLocation = CameraPosition(
      target: LatLng(
        widget.mapData.pointLatLngList[0].latitude,
        widget.mapData.pointLatLngList[0].longitude,
      ),
      zoom: 16,
    );
    _markers.add(Marker(
      markerId: MarkerId("home"),
      position: widget.mapData.pointLatLngList[0],
      draggable: false,
      zIndex: 2,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
    ));
    _markers.add(Marker(
      markerId: MarkerId("home"),
      position: widget
          .mapData.pointLatLngList[widget.mapData.pointLatLngList.length - 1],
      draggable: false,
      zIndex: 2,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    ));
    _polylines.add(Polyline(
      polylineId: PolylineId(
        "PolyLines",
      ),
      visible: true,
      points: widget.mapData.pointLatLngList,
      color: Colors.blue,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Preview",
        ),
      ),
      body: GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        polylines: _polylines,
        myLocationEnabled: true,
      ),
    );
  }
}
