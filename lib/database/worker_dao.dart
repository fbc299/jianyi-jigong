import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/worker.dart';

class WorkerDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Worker worker) async {
    final db = await _dbHelper.database;
    return await db.insert('workers', worker.toMap());
  }

  Future<int> update(Worker worker) async {
    final db = await _dbHelper.database;
    return await db.update('workers', worker.toMap(), where: 'id = ?', whereArgs: [worker.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('workers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Worker>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('workers', orderBy: 'created_at DESC');
    return maps.map((m) => Worker.fromMap(m)).toList();
  }

  Future<Worker?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('workers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Worker.fromMap(maps.first);
  }
}
