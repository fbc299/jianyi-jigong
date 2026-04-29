import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/work_provider.dart';
import '../../providers/salary_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/worker_provider.dart';
import '../../utils/format_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();
    context.read<WorkProvider>().loadMonthRecords(now.year, now.month);
    context.read<WorkProvider>().loadTodayRecords();
    context.read<SalaryProvider>().loadMonthRecords(now.year, now.month);
    context.read<ProjectProvider>().loadAll();
    context.read<WorkerProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('简约记工'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: '批量记工',
            onPressed: () => Navigator.pushNamed(context, '/work/batch'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/work/form'),
            tooltip: '记工',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          children: [
            _buildCalendar(),
            const Divider(),
            _buildQuickActions(),
            const Divider(),
            _buildSalaryOverview(),
            const Divider(),
            _buildTodaySummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<WorkProvider>(
      builder: (context, provider, _) {
        return TableCalendar(
          locale: 'zh_CN',
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            provider.loadRecordsByDate(selectedDay.toString().substring(0, 10));
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            provider.loadMonthRecords(focusedDay.year, focusedDay.month);
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final records = provider.records
                  .where((r) => r.date == day.toString().substring(0, 10))
                  .toList();
              if (records.isNotEmpty) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _buildQuickButton(Icons.work, '记工', () => Navigator.pushNamed(context, '/work/form')),
          _buildQuickButton(Icons.group_add, '批量记', () => Navigator.pushNamed(context, '/work/batch')),
          _buildQuickButton(Icons.attach_money, '记工资', () => Navigator.pushNamed(context, '/salary/form')),
          _buildQuickButton(Icons.bar_chart, '统计', () => Navigator.pushNamed(context, '/stats')),
        ],
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryOverview() {
    return Consumer<SalaryProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💰 本月工资概览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/salary/detail'),
                      child: const Text('明细 >'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSalaryRow('总工资', provider.totalSalary),
                _buildSalaryRow('已发放', provider.paidSalary),
                _buildSalaryRow('借支', provider.advanceSalary),
                const Divider(),
                _buildSalaryRow('待结算', provider.pendingSettle, isHighlight: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaryRow(String label, double amount, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          )),
          Text(
            FormatUtils.formatMoney(amount),
            style: TextStyle(
              fontSize: isHighlight ? 18 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary() {
    return Consumer<WorkProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📋 今日记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (provider.todayRecords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('今天还没有记工', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('立即记工'),
                            onPressed: () => Navigator.pushNamed(context, '/work/form'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.todayRecords.map((r) => ListTile(
                    dense: true,
                    leading: Icon(_getTypeIcon(r.type), size: 20),
                    title: Text(_getTypeName(r.type)),
                    subtitle: Text('${r.days ?? 0}天 ${r.hours ?? 0}小时'),
                    trailing: Text(FormatUtils.formatMoney(r.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
                if (provider.todayRecords.isNotEmpty) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('今日合计', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(FormatUtils.formatMoney(provider.todayTotal),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'point_day': return Icons.work;
      case 'point_hour': return Icons.access_time;
      case 'package_day': return Icons.workspaces;
      case 'package_quantity': return Icons.inventory;
      case 'overtime': return Icons.nightlight_round;
      default: return Icons.work;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'point_day': return '点工（按天）';
      case 'point_hour': return '点工（按小时）';
      case 'package_day': return '包工（按天）';
      case 'package_quantity': return '包工（按量）';
      case 'overtime': return '加班';
      default: return type;
    }
  }
}
