import 'dart:async';
import 'dart:core';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DataBaseStartTimeService {
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
    final dbPath = join(appDocumentDir.path, 'start_time_locationdto.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  StoreRef initStore() {
    return StoreRef.main();
  }

  Future<void> setUp() async {
    _database = await initDatabase();
    _store = initStore();
  }

  Future<DateTime> getStartTime() async {
    try {
      var dbClient = await database;
      var startTimeSnapShot = await store.findFirst(dbClient);
      return DateTime.parse(startTimeSnapShot!.value as String);
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future<void> insertStartTime(DateTime dateTime) async {
    try {
      var dbClient = await database;
      await store.add(dbClient, dateTime.toIso8601String());
    } catch (e) {
      //close();
      throw Exception(e.toString());
    }
  }

  Future<void> deleteStartTime() async {
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
  // static Box<String>? _dateTimeBox;

  // Future<Box<String>> get dateTimeBox async {
  //   if (_dateTimeBox != null) {
  //     return _dateTimeBox!;
  //   }
  //   await initDatabase();
  //   _dateTimeBox = await Hive.openBox<String>('myDateTimeBox');
  //   return _dateTimeBox!;
  // }

  // Future<void> initDatabase() async {
  //   var directory = await getApplicationDocumentsDirectory();
  //   String path = join(directory.path, 'hive_provider');
  //   if (await Directory(path).exists()) {
  //     await Directory(path).delete(recursive: true);
  //   }
  //   await Directory(path).create();
  //   Hive.init(path);
  // }

  // Future<void> setUp() async {
  //   _dateTimeBox = await dateTimeBox;
  // }

  // Future<DateTime> getStartTime() async {
  //   try {
  //     var box = await dateTimeBox;
  //     var jsonTime = box.get('start_time')!;
  //     return DateTime.parse(jsonTime);
  //   } catch (e) {
  //     close();
  //     throw Exception(e.toString());
  //   }
  // }

  // Future<void> insertStartTime(DateTime dateTime) async {
  //   try {
  //     var box = await dateTimeBox;
  //     box.put('start_time', dateTime.toIso8601String());
  //   } catch (e) {
  //     close();
  //     throw Exception(e.toString());
  //   }
  // }

  // Future<void> deleteStartTime() async {
  //   try {
  //     var box = await dateTimeBox;
  //     box.delete('start_time');
  //   } catch (e) {
  //     close();
  //     throw Exception(e.toString());
  //   }
  // }

  // Future close() async {
  //   Hive.close();
  // }
}
