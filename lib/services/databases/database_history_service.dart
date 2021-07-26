import 'dart:async';
import 'dart:core';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'package:app_map/model/map_data.dart';

class DatabaseHistoryService {
  static Database? _database;
  static StoreRef? _store;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  StoreRef get store {
    if (_store != null) {
      return _store!;
    }
    _store = StoreRef.main();
    return _store!;
  }

  Future<Database> initDatabase() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'map_datas.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  StoreRef initStore() {
    return StoreRef.main();
  }

  Future<void> setUp() async {
    _database = await initDatabase();
    _store = initStore();
  }

  Future<List<MapData>> getMapDataList() async {
    try {
      var dbClient = await database;
      var snapshot = await store.find(dbClient);

      List<MapData> mapDatas = [];
      if (snapshot.length != 0) {
        snapshot.forEach((element) {
          mapDatas.add(
            MapData.fromJson(element.value as String),
          );
        });
      }
      return mapDatas;
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future<void> insertMapData(MapData mapData) async {
    try {
      var dbClient = await database;
      await store.add(dbClient, mapData.toJson());
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future<void> deleteMapDatas() async {
    try {
      final dbClient = await database;
      int count = await store.delete(dbClient);
      print(count);
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future close() async {
    var dbClient = await database;
    dbClient.close();
  }
}
