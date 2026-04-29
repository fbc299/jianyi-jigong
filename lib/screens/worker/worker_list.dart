import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../utils/format_utils.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkerProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u5de5\u4eba\u7ba1\u7406')),
      body: Consumer<WorkerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.workers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('\u8fd8\u6ca1\u6709\u5de5\u4eba', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('\u70b9\u51fb\u53f3\u4e0b\u89d2\u6dfb\u52a0', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.workers.length,
            itemBuilder: (context, index) {
              final w = provider.workers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    [w.skill ?? '', w.dailyRate != null ? '\u65e5\u85aa: \${FormatUtils.formatMoney(w.dailyRate!)}' : ''].where((s) => s.isNotEmpty).join(' | '),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: w.phone != null && w.phone!.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () {})
                      : null,
                  onTap: () => Navigator.pushNamed(context, '/worker/form', arguments: w),
                  onLongPress: () => _showDeleteDialog(context, provider, w.id!, w.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/worker/form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WorkerProvider provider, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('\u5220\u9664\u5de5\u4eba'),
        content: Text('\u786e\u5b9a\u5220\u9664\u201c$name\u201d\u5417\uff1f'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u53d6\u6d88')),
          TextButton(
            onPressed: () { provider.deleteWorker(id); Navigator.pop(ctx); },
            child: const Text('\u5220\u9664', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
