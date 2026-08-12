import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/storage.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db == null) {
      await init();
      return _db!;
    }

    return _db!;
  }

  static Future<void> init() async {
    _db = await Storage.init('favorites_database');
  }

  static Future<List<Map<String, dynamic>>> read() async {
    Database db = await database;
    return await db.query('Favorites');
  }

  static Future<void> insert(Product item) async {
    Database db = await database;
    await db.insert(
      'Favorites',
      {
        "ID": item.id,
        "Name": item.name,
        "Category": item.category.label,
        "Price": item.price,
        "Description": item.description,
        "URL": item.imageURL
      }
    );
  }

  static Future<void> remove(int id) async {
    Database db = await database;
    await db.delete(
      'Favorites',
      where: 'ID = ?',
      whereArgs: [id]
    );
  }
}