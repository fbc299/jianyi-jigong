import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/salary_record.dart';

class SalaryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(SalaryRecord record) async {
    final db = await _dbHelper.database;
    return await db.insert('salary_records', record.toMap());
  }

  Future<int> update(SalaryRecord record) async {
    final db = await _dbHelper.database;
    return await db.update(
      'salary_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('salary_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SalaryRecord>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('salary_records', orderBy: 'date DESC');
    return maps.map((m) => SalaryRecord.fromMap(m)).toList();
  }

  Future<List<SalaryRecord>> getByMonth(int year, int month) async {
    final start = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final end = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    final db = await _dbHelper.database;
    final maps = await db.query(
      'salary_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => SalaryRecord.fromMap(m)).toList();
  }

  Future<List<SalaryRecord>> getRecordsByDateRange(String start, String end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'salary_records',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => SalaryRecord.fromMap(m)).toList();
  }

  Future<SalaryRecord?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('salary_records', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return SalaryRecord.fromMap(maps.first);
  }
}
