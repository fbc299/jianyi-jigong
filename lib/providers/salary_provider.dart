import 'package:flutter/material.dart';
import '../models/salary_record.dart';
import '../database/salary_dao.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryDao _dao = SalaryDao();
  List<SalaryRecord> _records = [];
  bool _isLoading = false;

  List<SalaryRecord> get records => _records;
  bool get isLoading => _isLoading;

  double get totalSalary => _records
      .where((r) => r.type == 'total')
      .fold(0.0, (sum, r) => sum + r.amount);

  double get paidSalary => _records
      .where((r) => r.type == 'paid')
      .fold(0.0, (sum, r) => sum + r.amount);

  double get advanceSalary => _records
      .where((r) => r.type == 'advance')
      .fold(0.0, (sum, r) => sum + r.amount);

  double get settledSalary => _records
      .where((r) => r.type == 'settle')
      .fold(0.0, (sum, r) => sum + r.amount);

  double get pendingSettle => totalSalary - paidSalary - advanceSalary;

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

  Future<void> addRecord(SalaryRecord record) async {
    await _dao.insert(record);
    final now = DateTime.now();
    await loadMonthRecords(now.year, now.month);
  }

  Future<void> updateRecord(SalaryRecord record) async {
    await _dao.update(record);
    final now = DateTime.now();
    await loadMonthRecords(now.year, now.month);
  }

  Future<void> deleteRecord(int id) async {
    await _dao.delete(id);
    final now = DateTime.now();
    await loadMonthRecords(now.year, now.month);
  }
}
