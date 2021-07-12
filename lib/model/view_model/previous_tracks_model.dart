import 'package:flutter/foundation.dart';

import 'package:app_map/model/map_data.dart';

class PreviousTrackViewModel extends ChangeNotifier {
  List<MapData> _mapDatas = [];
  List<MapData> get mapDatas => this._mapDatas;

  void addNewMapData(MapData value) {
    this._mapDatas.add(value);
    notifyListeners();
  }
}
