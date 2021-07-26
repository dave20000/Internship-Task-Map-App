import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapData {
  final double totalDistance;
  final DateTime startTime;
  final DateTime endTime;
  final List<LatLng> pointLatLngList;
  MapData({
    required this.totalDistance,
    required this.startTime,
    required this.endTime,
    required this.pointLatLngList,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalDistance': totalDistance,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'pointLatLngList': pointLatLngList
          .map(
            (x) => {
              'latitude': x.latitude,
              'longitude': x.longitude,
            },
          )
          .toList(),
    };
  }

  factory MapData.fromMap(Map<String, dynamic> map) {
    return MapData(
      totalDistance: map['totalDistance'] as double,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      pointLatLngList: List<LatLng>.from(
        map['pointLatLngList'].map(
          (x) => LatLng(
            x['latitude'],
            x['longitude'],
          ),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MapData.fromJson(String source) =>
      MapData.fromMap(json.decode(source));
}
