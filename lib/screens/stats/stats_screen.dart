import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/work_provider.dart';
import '../../providers/salary_provider.dart';
import '../../utils/format_utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<WorkProvider>().loadMonthRecords(_selectedYear, _selectedMonth);
    context.read<SalaryProvider>().loadMonthRecords(_selectedYear, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonth,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '年度统计',
            onPressed: () => Navigator.pushNamed(context, '/stats/yearly'),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildMonthSelector(),
          _buildWorkStats(),
          _buildSalaryStats(),
          _buildTypeChart(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth--;
                if (_selectedMonth < 1) {
                  _selectedMonth = 12;
                  _selectedYear--;
                }
              });
              _loadData();
            },
          ),
          Text(
            '\$_selectedYear年\$_selectedMonth月',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth++;
                if (_selectedMonth > 12) {
                  _selectedMonth = 1;
                  _selectedYear++;
                }
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStats() {
    return Consumer<WorkProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 工时统计', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('工天', '\${provider.getMonthWorkDays()}', '天'),
                    _buildStatItem('记录数', '\${provider.records.length}', '条'),
                    _buildStatItem('总金额', FormatUtils.formatMoney(provider.getMonthTotal()), ''),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaryStats() {
    return Consumer<SalaryProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💰 工资统计', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/salary/detail'),
                      child: const Text('明细表 >'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSalaryRow('总工资', provider.totalSalary, Colors.green),
                _buildSalaryRow('已发放', provider.paidSalary, Colors.blue),
                _buildSalaryRow('借支', provider.advanceSalary, Colors.orange),
                const Divider(),
                _buildSalaryRow('待结算', provider.pendingSettle, Colors.red, isBold: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('\$label\$unit', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSalaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            FormatUtils.formatMoney(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChart() {
    return Consumer<WorkProvider>(
      builder: (context, provider, _) {
        if (provider.records.isEmpty) {
          return const SizedBox.shrink();
        }

        final typeMap = <String, double>{};
        for (final r in provider.records) {
          typeMap[r.type] = (typeMap[r.type] ?? 0) + r.totalAmount;
        }

        final colors = [Colors.blue, Colors.cyan, Colors.green, Colors.teal, Colors.orange];
        final names = {
          'point_day': '点工(天)',
          'point_hour': '点工(时)',
          'package_day': '包工(天)',
          'package_quantity': '包工(量)',
          'overtime': '加班',
        };

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📈 工种分布', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: typeMap.entries.toList().asMap().entries.map((e) {
                        return PieChartSectionData(
                          value: e.value.value,
                          title: '\${e.value.value.toStringAsFixed(0)}',
                          color: colors[e.key % colors.length],
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  children: typeMap.entries.toList().asMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: colors[e.key % colors.length]),
                        const SizedBox(width: 4),
                        Text(names[e.value.key] ?? e.value.key, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
      });
      _loadData();
    }
  }
}
