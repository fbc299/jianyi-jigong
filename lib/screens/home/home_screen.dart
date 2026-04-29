import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../providers/work_provider.dart';
import '../../providers/salary_provider.dart';
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
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _initLocale();
    _loadData();
  }

  Future<void> _initLocale() async {
    await initializeDateFormatting('zh_CN');
    if (mounted) setState(() => _localeReady = true);
  }

  void _loadData() {
    final now = DateTime.now();
    context.read<WorkProvider>().loadMonthRecords(now.year, now.month);
    context.read<WorkProvider>().loadTodayRecords();
    context.read<SalaryProvider>().loadMonthRecords(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u7b80\u7ea6\u8bb0\u5de5'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/work/form'),
            tooltip: '\u8bb0\u5de5',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          children: [
            if (_localeReady) _buildCalendar() else const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                Text('\ud83d\udcb0 \u672c\u6708\u5de5\u8d44\u6982\u89c8', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildSalaryRow('\u603b\u5de5\u8d44', provider.totalSalary),
                _buildSalaryRow('\u5df2\u53d1\u653e', provider.paidSalary),
                _buildSalaryRow('\u501f\u652f', provider.advanceSalary),
                const Divider(),
                _buildSalaryRow('\u5f85\u7ed3\u7b97', provider.pendingSettle, isHighlight: true),
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
                Text('\ud83d\udccb \u4eca\u65e5\u8bb0\u5f55', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (provider.todayRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('\u4eca\u5929\u8fd8\u6ca1\u6709\u8bb0\u5de5', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...provider.todayRecords.map((r) => ListTile(
                    dense: true,
                    leading: Icon(_getTypeIcon(r.type), size: 20),
                    title: Text(_getTypeName(r.type)),
                    subtitle: Text('\${r.days ?? 0}\u5929 \${r.hours ?? 0}\u5c0f\u65f6'),
                    trailing: Text(FormatUtils.formatMoney(r.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('\u4eca\u65e5\u5408\u8ba1', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(FormatUtils.formatMoney(provider.todayTotal),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                  ],
                ),
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
      case 'point_day': return '\u70b9\u5de5\uff08\u6309\u5929\uff09';
      case 'point_hour': return '\u70b9\u5de5\uff08\u6309\u5c0f\u65f6\uff09';
      case 'package_day': return '\u5305\u5de5\uff08\u6309\u5929\uff09';
      case 'package_quantity': return '\u5305\u5de5\uff08\u6309\u91cf\uff09';
      case 'overtime': return '\u52a0\u73ed';
      default: return type;
    }
  }
}
