import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Storage {
  static Future<Database> init(String dbName) async {
    return await openDatabase(
      join(await getDatabasesPath(), '$dbName.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE FAVORITES (ID INTEGER PRIMARY KEY, Name Text, Category Text, Price REAL, Description Text, URL Text)',
        );
      },
      version: 1,
    );
  }
}