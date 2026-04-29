import 'package:flutter/material.dart';
import '../models/work_record.dart';
import '../database/work_dao.dart';

class WorkProvider extends ChangeNotifier {
  final WorkDao _dao = WorkDao();
  List<WorkRecord> _records = [];
  List<WorkRecord> _todayRecords = [];
  bool _isLoading = false;

  List<WorkRecord> get records => _records;
  List<WorkRecord> get todayRecords => _todayRecords;
  bool get isLoading => _isLoading;

  double get todayTotal => _todayRecords.fold(0.0, (sum, r) => sum + (r.totalAmount ?? 0));

  Future<void> loadTodayRecords() async {
    _isLoading = true;
    notifyListeners();
    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _todayRecords = await _dao.getRecordsByDate(dateStr);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMonthRecords(int year, int month) async {
    _isLoading = true;
    notifyListeners();
    final startDate = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final endDate = '${endYear.toString().padLeft(4, '0')}-${endMonth.toString().padLeft(2, '0')}-01';
    _records = await _dao.getRecordsByDateRange(startDate, endDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecordsByDate(String date) async {
    _todayRecords = await _dao.getRecordsByDate(date);
    notifyListeners();
  }

  Future<void> addRecord(WorkRecord record) async {
    await _dao.insert(record);
    await loadTodayRecords();
  }

  Future<void> updateRecord(WorkRecord record) async {
    await _dao.update(record);
    await loadTodayRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _dao.delete(id);
    await loadTodayRecords();
  }

  double getMonthTotal() {
    return _records.fold(0.0, (sum, r) => sum + (r.totalAmount ?? 0));
  }

  int getMonthWorkDays() {
    final dates = _records.map((r) => r.date).toSet();
    return dates.length;
  }

  Map<String, List<WorkRecord>> groupByDate() {
    final map = <String, List<WorkRecord>>{};
    for (final r in _records) {
      map.putIfAbsent(r.date, () => []).add(r);
    }
    return map;
  }
}
