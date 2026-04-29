class AppConstants {
  static const String appName = '简约记工';
  static const String appVersion = '2.0.0';
  static const String dbName = 'jianyi_jigong.db';
  static const int dbVersion = 1;

  // Work types
  static const String workTypePointDay = 'point_day';
  static const String workTypePointHour = 'point_hour';
  static const String workTypePackageDay = 'package_day';
  static const String workTypePackageQuantity = 'package_quantity';
  static const String workTypeOvertime = 'overtime';

  static const Map<String, String> workTypeLabels = {
    workTypePointDay: '点工(按天)',
    workTypePointHour: '点工(按小时)',
    workTypePackageDay: '包工(按天)',
    workTypePackageQuantity: '包工(按量)',
    workTypeOvertime: '加班',
  };

  // Salary types
  static const String salaryTypeTotal = 'total';
  static const String salaryTypePaid = 'paid';
  static const String salaryTypeAdvance = 'advance';
  static const String salaryTypeSettle = 'settle';

  static const Map<String, String> salaryTypeLabels = {
    salaryTypeTotal: '总工资',
    salaryTypePaid: '已发放',
    salaryTypeAdvance: '借支/预支',
    salaryTypeSettle: '结算',
  };
}
