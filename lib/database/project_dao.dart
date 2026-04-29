import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/project.dart';

class ProjectDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Project project) async {
    final db = await _dbHelper.database;
    return await db.insert('projects', project.toMap());
  }

  Future<int> update(Project project) async {
    final db = await _dbHelper.database;
    return await db.update('projects', project.toMap(), where: 'id = ?', whereArgs: [project.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Project>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('projects', orderBy: 'created_at DESC');
    return maps.map((m) => Project.fromMap(m)).toList();
  }

  Future<List<Project>> getActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query('projects', where: "status = 'active'", orderBy: 'created_at DESC');
    return maps.map((m) => Project.fromMap(m)).toList();
  }

  Future<Project?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Project.fromMap(maps.first);
  }
}
