// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_locator.dart';

// **************************************************************************
// KiwiInjectorGenerator
// **************************************************************************

class _$ServiceLocator extends ServiceLocator {
  @override
  void _configure() {
    final KiwiContainer container = KiwiContainer();
    container.registerSingleton((c) => MapViewModel(
        c<MapLocationDatabaseService>(), c<DataBaseStartTimeService>()));
    container.registerSingleton(
        (c) => PreviousTrackViewModel(c<DatabaseHistoryService>()));
    container.registerSingleton(
        (c) => BackgroundTrackViewModel(c<MapLocationDatabaseService>()));
    container.registerSingleton((c) => MapLocationDatabaseService());
    container.registerSingleton((c) => DataBaseStartTimeService());
    container.registerSingleton((c) => DatabaseHistoryService());
  }
}
