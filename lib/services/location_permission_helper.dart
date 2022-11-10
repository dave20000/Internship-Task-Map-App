import 'package:geolocator/geolocator.dart';

class LocationPermissionHelper {
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

  Future<bool> handleOnboardingPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<bool> checkPermissionStatus() async {
    final hasLocationService = await handleLocationService();
    if (hasLocationService) {
      final hasPermission = await handlePermission();
      if (hasPermission) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> handleLocationService() async {
    bool serviceEnabled;
    serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    return true;
  }

  Future<bool> handlePermission() async {
    LocationPermission permission;
    permission = await geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> openLocationSettings() async {
    final opened = await geolocatorPlatform.openLocationSettings();
    if (opened) {
      print('Opened Location Settings');
    } else {
      print('Error opening Location Settings');
    }
  }

  Future<void> openAppSettings() async {
    final opened = await geolocatorPlatform.openAppSettings();
    if (opened) {
      print('Opened Application Settings.');
    } else {
      print('Error opening Application Settings.');
    }
  }
}
