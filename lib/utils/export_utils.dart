import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/work_dao.dart';
import '../database/salary_dao.dart';
import '../database/project_dao.dart';
import '../database/worker_dao.dart';

class ExportUtils {
  static Future<File> exportToJson() async {
    final workDao = WorkDao();
    final salaryDao = SalaryDao();
    final projectDao = ProjectDao();
    final workerDao = WorkerDao();

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '2.0.0',
      'workRecords': (await workDao.getAll()).map((r) => r.toMap()).toList(),
      'salaryRecords': (await salaryDao.getAll()).map((r) => r.toMap()).toList(),
      'projects': (await projectDao.getAll()).map((p) => p.toMap()).toList(),
      'workers': (await workerDao.getAll()).map((w) => w.toMap()).toList(),
    };

    final encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(data);

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/jianyi_backup_$timestamp.json');
    return file.writeAsString(json);
  }

  static Future<File> exportWorkToCsv() async {
    final records = await WorkDao().getAll();
    final buffer = StringBuffer();
    buffer.writeln('日期,类型,天数,小时,数量,单价,金额,项目ID,工人ID,备注');

    for (final r in records) {
      buffer.writeln(
        '${r.date},${_typeLabel(r.type)},${r.days ?? 0},${r.hours ?? 0},'
        '${r.quantity ?? 0},${r.unitPrice ?? 0},${r.totalAmount},'
        "${r.projectId ?? ''},${r.workerId ?? ''},${r.remark ?? ''}",
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/jianyi_work_$timestamp.csv');
    return file.writeAsString(buffer.toString());
  }

  static Future<File> exportSalaryToCsv() async {
    final records = await SalaryDao().getAll();
    final buffer = StringBuffer();
    buffer.writeln('日期,类型,金额,支付方式,周期开始,周期结束,备注');

    for (final r in records) {
      buffer.writeln(
        '${r.date},${_salaryTypeLabel(r.type)},${r.amount},'
        "${r.paymentMethod ?? ''},${r.periodStart ?? ''},"
        "${r.periodEnd ?? ''},${r.remark ?? ''}",
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/jianyi_salary_$timestamp.csv');
    return file.writeAsString(buffer.toString());
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'point_day': return '点工(按天)';
      case 'point_hour': return '点工(按小时)';
      case 'package_day': return '包工(按天)';
      case 'package_quantity': return '包工(按量)';
      case 'overtime': return '加班';
      default: return type;
    }
  }

  static String _salaryTypeLabel(String type) {
    switch (type) {
      case 'total': return '总工资';
      case 'paid': return '已发放';
      case 'advance': return '借支';
      case 'settle': return '结算';
      default: return type;
    }
  }
}
