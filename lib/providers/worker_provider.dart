import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../database/worker_dao.dart';

class WorkerProvider extends ChangeNotifier {
  final WorkerDao _dao = WorkerDao();
  List<Worker> _workers = [];
  bool _isLoading = false;

  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _workers = await _dao.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWorker(Worker worker) async {
    await _dao.insert(worker);
    await loadAll();
  }

  Future<void> updateWorker(Worker worker) async {
    await _dao.update(worker);
    await loadAll();
  }

  Future<void> deleteWorker(int id) async {
    await _dao.delete(id);
    await loadAll();
  }

  Worker? getWorkerById(int? id) {
    if (id == null) return null;
    try {
      return _workers.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
