import 'dart:async';
import 'dart:core';

import 'package:background_locator/location_dto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class MapLocationDatabaseService {
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
    final dbPath = join(appDocumentDir.path, 'temp_loc_data.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  StoreRef initStore() {
    return StoreRef.main();
  }

  Future<void> setUp() async {
    _database = await initDatabase();
    _store = initStore();
  }

  Future<List<LocationDto>> getLocations() async {
    try {
      var dbClient = await database;
      final snapshot = await store.find(dbClient);
      print("Location Dtos count :" + snapshot.length.toString());
      return snapshot.map((e) => LocationDto.fromJson(e.value)).toList();
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future<void> insertLocationDto(LocationDto locationDto) async {
    try {
      var dbClient = await database;
      await store.add(dbClient, locationDto.toJson());
      print("mf i am here");
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future<void> deleteLocations() async {
    try {
      final dbClient = await database;
      int count = await store.delete(dbClient);
      print("Deleted location count: " + count.toString());
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future close() async {
    var dbClient = await database;
    dbClient.close();
  }
  // static Database? _database;

  // Future<Database> get database async {
  //   if (_database != null) {
  //     return _database!;
  //   }
  //   _database = await initDatabase();
  //   return _database!;
  // }

  // initDatabase() async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String path = join(directory.path, 'map_app.db');
  //   return await openDatabase(path, version: 1, onCreate: _onCreate);
  // }

  // _onCreate(Database db, int version) async {
  //   await db.execute(
  //     """CREATE TABLE locationsDtoss (latitude REAL,
  //     longitude REAL, accuracy REAL, altitude REAL,speed REAL,
  //     speedAccuracy REAL, heading REAL, time REAL,isMocked BOOLEAN)""",
  //   );
  // }

  // Future<List<LocationDto>> getLocations() async {
  //   try {
  //     var dbClient = await database;
  //     List<Map> jsonLocationDtos = await dbClient.query('locationsDtoss');
  //     List<LocationDto> locationDtos = [];
  //     if (jsonLocationDtos.length > 0) {
  //       for (int i = 0; i < jsonLocationDtos.length; i++) {
  //         locationDtos.add(LocationDto.fromJson(jsonLocationDtos[i]));
  //       }
  //     }
  //     return locationDtos;
  //   } catch (e) {
  //     close();
  //     throw Exception(e.toString());
  //   }
  // }

  // Future<int> insertLocationDto(LocationDto locationDto) async {
  //   try {
  //     var dbClient = await database;
  //     return await dbClient.insert('locationsDtoss', locationDto.toJson());
  //   } catch (e) {
  //     close();
  //     throw Exception(e.toString());
  //   }
  // }

  // Future deleteLocations() async {
  //   try {
  //     final db = await database;
  //     await db.delete("locationsDtoss");
  //   } catch (e) {
  //     close();
  //     throw Exception(e.toString());
  //   }
  // }

  // Future close() async {
  //   var dbClient = await database;
  //   dbClient.close();
  // }
}
