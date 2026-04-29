import 'package:flutter/material.dart';
import '../models/project.dart';
import '../database/project_dao.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectDao _dao = ProjectDao();
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  List<Project> get activeProjects => _projects.where((p) => p.status == 'active').toList();
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _projects = await _dao.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await _dao.insert(project);
    await loadAll();
  }

  Future<void> updateProject(Project project) async {
    await _dao.update(project);
    await loadAll();
  }

  Future<void> deleteProject(int id) async {
    await _dao.delete(id);
    await loadAll();
  }

  Project? getProjectById(int? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
