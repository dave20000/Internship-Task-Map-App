import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapData {
  double totalDistance;
  String timeTaken;
  DateTime startTime;
  DateTime endTime;
  List<LatLng> pointLatLngList;
  MapData({
    required this.totalDistance,
    required this.timeTaken,
    required this.startTime,
    required this.endTime,
    required this.pointLatLngList,
  });
}
