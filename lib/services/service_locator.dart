import 'package:kiwi/kiwi.dart';

import 'package:app_map/model/view_model/background_track_model.dart';
import 'package:app_map/model/view_model/map_model.dart';
import 'package:app_map/model/view_model/previous_tracks_model.dart';
import 'package:app_map/services/databases/database_history_service.dart';
import 'package:app_map/services/databases/database_service.dart';
import 'package:app_map/services/databases/database_start_time.dart';

part 'service_locator.g.dart';

abstract class ServiceLocator {
  static KiwiContainer? container;

  static void setup() {
    container = KiwiContainer();
    _$ServiceLocator()._configure();
  }

  static final resolve = container!.resolve;

  @Register.singleton(MapViewModel)
  @Register.singleton(PreviousTrackViewModel)
  @Register.singleton(BackgroundTrackViewModel)
  @Register.singleton(MapLocationDatabaseService)
  @Register.singleton(DataBaseStartTimeService)
  @Register.singleton(DatabaseHistoryService)
  void _configure();
}
