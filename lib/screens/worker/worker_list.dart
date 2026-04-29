import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../models/worker.dart';
import '../../utils/format_utils.dart';

class WorkerListScreen extends StatelessWidget {
  const WorkerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('工人管理')),
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
                  const Text('还没有工人', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('点击右下角添加工人信息', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.workers.length,
            itemBuilder: (context, index) {
              final worker = provider.workers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      worker.name.isNotEmpty ? worker.name[0] : '?',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (worker.phone?.isNotEmpty == true)
                        Text('📱 ${worker.phone}', style: const TextStyle(fontSize: 12)),
                      if (worker.skill?.isNotEmpty == true)
                        Text('🔧 ${worker.skill}', style: const TextStyle(fontSize: 12)),
                      if (worker.dailyRate != null && worker.dailyRate! > 0)
                        Text('💰 日薪: ${FormatUtils.formatMoney(worker.dailyRate!)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('编辑')),
                      const PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(context, '/worker/form', arguments: worker);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, provider, worker);
                      }
                    },
                  ),
                  onTap: () => Navigator.pushNamed(context, '/worker/form', arguments: worker),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/worker/form'),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WorkerProvider provider, Worker worker) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除工人'),
        content: Text('确定删除「${worker.name}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              provider.deleteWorker(worker.id!);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
