import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/work_record.dart';

class WorkDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(WorkRecord record) async {
    final db = await _dbHelper.database;
    return await db.insert('work_records', record.toMap());
  }

  Future<int> update(WorkRecord record) async {
    final db = await _dbHelper.database;
    return await db.update(
      'work_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('work_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkRecord>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('work_records', orderBy: 'date DESC');
    return maps.map((m) => WorkRecord.fromMap(m)).toList();
  }

  Future<List<WorkRecord>> getByDateRange(String start, String end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'work_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => WorkRecord.fromMap(m)).toList();
  }

  Future<List<WorkRecord>> getByMonth(int year, int month) async {
    final start = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final end = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    return getByDateRange(start, end);
  }

  Future<List<WorkRecord>> getRecordsByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'work_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'date DESC',
    );
    return maps.map((m) => WorkRecord.fromMap(m)).toList();
  }

  Future<List<WorkRecord>> getRecordsByDateRange(String start, String end) async {
    return getByDateRange(start, end);
  }

  Future<WorkRecord?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('work_records', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return WorkRecord.fromMap(maps.first);
  }
}
