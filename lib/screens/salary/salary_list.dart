import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/salary_provider.dart';
import '../../utils/format_utils.dart';

class SalaryListScreen extends StatelessWidget {
  const SalaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u5de5\u8d44\u7ba1\u7406'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.table_chart),
            label: const Text('\u660e\u7ec6\u8868'),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<SalaryProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      const Text('\ud83d\udcb0 \u5f85\u7ed3\u7b97', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        FormatUtils.formatMoney(provider.pendingSettle),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildActionButton(context, '\u8bb0\u5de5\u8d44', Icons.add_circle, Colors.blue, 'total')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(context, '\u8bb0\u501f\u652f', Icons.money_off, Colors.orange, 'advance')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(context, '\u8bb0\u7ed3\u7b97', Icons.check_circle, Colors.green, 'settle')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('\ud83d\udccb \u6700\u8fd1\u8bb0\u5f55', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Text('\${provider.records.length}\u6761', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: provider.records.isEmpty
                    ? const Center(child: Text('\u6682\u65e0\u8bb0\u5f55', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: provider.records.length,
                        itemBuilder: (context, index) {
                          final r = provider.records[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getTypeColor(r.type).withValues(alpha: 0.1),
                              child: Icon(_getTypeIcon(r.type), color: _getTypeColor(r.type), size: 20),
                            ),
                            title: Text(_getTypeName(r.type)),
                            subtitle: Text('\${r.date} \${r.remark ?? ''}'),
                            trailing: Text(
                              '\${r.type == 'total' ? '+' : '-'}\${FormatUtils.formatMoney(r.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: r.type == 'total' ? Colors.green : Colors.red,
                              ),
                            ),
                            onTap: () => Navigator.pushNamed(context, '/salary/form', arguments: r),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/salary/form'),
        icon: const Icon(Icons.add),
        label: const Text('\u8bb0\u5de5\u8d44'),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, String type) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/salary/form', arguments: type),
      icon: Icon(icon, color: color, size: 18),
      label: Text(label),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'total': return Colors.green;
      case 'paid': return Colors.blue;
      case 'advance': return Colors.orange;
      case 'settle': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'total': return Icons.attach_money;
      case 'paid': return Icons.payments;
      case 'advance': return Icons.money_off;
      case 'settle': return Icons.check_circle;
      default: return Icons.money;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'total': return '\u603b\u5de5\u8d44';
      case 'paid': return '\u5df2\u53d1\u653e';
      case 'advance': return '\u501f\u652f/\u9884\u652f';
      case 'settle': return '\u7ed3\u7b97';
      default: return type;
    }
  }
}
