import 'package:flutter/foundation.dart';

import 'package:app_map/model/map_data.dart';
import 'package:app_map/services/databases/database_history_service.dart';

class PreviousTrackViewModel extends ChangeNotifier {
  DatabaseHistoryService _databaseHistoryService;

  List<MapData> _mapDatas = [];
  List<MapData> get mapDatas => this._mapDatas;

  // void addNewMapData(MapData value) {
  //   this._mapDatas.add(value);
  //   notifyListeners();
  // }

  PreviousTrackViewModel(this._databaseHistoryService);

  Future<void> insertMapData(MapData mapData) async {
    await _databaseHistoryService.insertMapData(mapData);
    await getMapDatas();
  }

  Future<void> getMapDatas() async {
    _mapDatas = await _databaseHistoryService.getMapDataList();
    notifyListeners();
  }

  Future<void> deleteMapDatas() async {
    await _databaseHistoryService.deleteMapDatas();
    getMapDatas();
  }

  Future<void> deleteMapData(MapData mapData) async {
    await _databaseHistoryService.deleteMapData(mapData);
    getMapDatas();
    // _mapDatas.remove(mapData);
    // notifyListeners();
  }
}
