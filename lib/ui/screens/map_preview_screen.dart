import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPreviewScreen extends StatefulWidget {
  final List<LatLng> latLngPoints;
  const MapPreviewScreen({
    required this.latLngPoints,
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
        widget.latLngPoints[0].latitude,
        widget.latLngPoints[0].longitude,
      ),
      zoom: 14,
    );
    _markers.add(Marker(
      markerId: MarkerId("home"),
      position: widget.latLngPoints[0],
      draggable: false,
      zIndex: 2,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
    ));
    _markers.add(Marker(
      markerId: MarkerId("home"),
      position: widget.latLngPoints[widget.latLngPoints.length - 1],
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
      points: widget.latLngPoints,
      color: Colors.blue,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
