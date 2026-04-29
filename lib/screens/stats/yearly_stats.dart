import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/work_provider.dart';
import '../../providers/salary_provider.dart';
import '../../database/work_dao.dart';
import '../../database/salary_dao.dart';
import '../../utils/format_utils.dart';

class YearlyStatsScreen extends StatefulWidget {
  const YearlyStatsScreen({super.key});

  @override
  State<YearlyStatsScreen> createState() => _YearlyStatsScreenState();
}

class _YearlyStatsScreenState extends State<YearlyStatsScreen> {
  int _selectedYear = DateTime.now().year;
  Map<int, double> _monthlyWorkTotals = {};
  Map<int, double> _monthlySalaryTotals = {};
  double _yearTotal = 0;
  int _yearWorkDays = 0;
  double _yearSalaryTotal = 0;
  double _yearSalaryPaid = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadYearData();
  }

  Future<void> _loadYearData() async {
    setState(() => _isLoading = true);
    final workDao = WorkDao();
    final salaryDao = SalaryDao();

    final monthlyWork = <int, double>{};
    final monthlySalary = <int, double>{};
    double totalWork = 0;
    int totalDays = 0;
    double totalSalary = 0;
    double totalPaid = 0;

    for (int month = 1; month <= 12; month++) {
      final records = await workDao.getByMonth(_selectedYear, month);
      final monthTotal = records.fold<double>(0, (s, r) => s + r.totalAmount);
      final monthDays = records.map((r) => r.date).toSet().length;
      monthlyWork[month] = monthTotal;
      totalWork += monthTotal;
      totalDays += monthDays;

      final salaryRecords = await salaryDao.getByMonth(_selectedYear, month);
      final salaryTotal = salaryRecords
          .where((r) => r.type == 'total')
          .fold<double>(0, (s, r) => s + r.amount);
      final salaryPaid = salaryRecords
          .where((r) => r.type == 'paid' || r.type == 'settle')
          .fold<double>(0, (s, r) => s + r.amount);
      monthlySalary[month] = salaryTotal;
      totalSalary += salaryTotal;
      totalPaid += salaryPaid;
    }

    setState(() {
      _monthlyWorkTotals = monthlyWork;
      _monthlySalaryTotals = monthlySalary;
      _yearTotal = totalWork;
      _yearWorkDays = totalDays;
      _yearSalaryTotal = totalSalary;
      _yearSalaryPaid = totalPaid;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('年度统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() => _selectedYear--);
              _loadYearData();
            },
          ),
          Center(
            child: Text('$_selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() => _selectedYear++);
              _loadYearData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Year summary
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('$_selectedYear年汇总', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('总工天', '$_yearWorkDays天'),
                            _buildSummaryItem('总工钱', FormatUtils.formatMoney(_yearTotal)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('总工资', FormatUtils.formatMoney(_yearSalaryTotal)),
                            _buildSummaryItem('已发放', FormatUtils.formatMoney(_yearSalaryPaid)),
                          ],
                        ),
                        const Divider(),
                        _buildSummaryItem(
                          '待结算',
                          FormatUtils.formatMoney(_yearSalaryTotal - _yearSalaryPaid),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Monthly bar chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📊 月度工钱趋势', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _monthlyWorkTotals.isEmpty
                              ? const Center(child: Text('暂无数据'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _monthlyWorkTotals.values.fold<double>(0, (a, b) => a > b ? a : b) * 1.2,
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${group.x + 1}月\n${FormatUtils.formatMoney(rod.toY)}',
                                            const TextStyle(color: Colors.white, fontSize: 12),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text('${value.toInt() + 1}月', style: const TextStyle(fontSize: 10)),
                                            );
                                          },
                                          reservedSize: 28,
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 50,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value >= 10000 ? '${(value / 10000).toStringAsFixed(1)}万' : value.toInt().toString(),
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: _monthlyWorkTotals.values.fold<double>(0, (a, b) => a > b ? a : b) / 4,
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: _monthlyWorkTotals.entries.map((e) {
                                      return BarChartGroupData(
                                        x: e.key - 1,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value,
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 16,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Monthly breakdown table
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📋 月度明细', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text('月份', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text('工钱', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text('工资', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            ...List.generate(12, (i) {
                              final month = i + 1;
                              final workTotal = _monthlyWorkTotals[month] ?? 0;
                              final salaryTotal = _monthlySalaryTotals[month] ?? 0;
                              return TableRow(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Text('$month月', style: const TextStyle(fontSize: 13)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Text(
                                      workTotal > 0 ? FormatUtils.formatMoney(workTotal) : '-',
                                      style: TextStyle(fontSize: 13, color: workTotal > 0 ? null : Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Text(
                                      salaryTotal > 0 ? FormatUtils.formatMoney(salaryTotal) : '-',
                                      style: TextStyle(fontSize: 13, color: salaryTotal > 0 ? null : Colors.grey),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
