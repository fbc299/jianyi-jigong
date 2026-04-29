import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u9879\u76ee\u7ba1\u7406')),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('\u8fd8\u6ca1\u6709\u9879\u76ee', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('\u70b9\u51fb\u53f3\u4e0b\u89d2\u6dfb\u52a0', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final p = provider.projects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.status == 'active' ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    child: Icon(Icons.folder, color: p.status == 'active' ? Colors.green : Colors.grey),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p.address ?? '\u672a\u8bbe\u5730\u5740', style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.status == 'active' ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.status == 'active' ? '\u8fdb\u884c\u4e2d' : '\u5df2\u5b8c\u5de5',
                          style: TextStyle(fontSize: 11, color: p.status == 'active' ? Colors.green : Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, '/project/form', arguments: p),
                  onLongPress: () => _showDeleteDialog(context, provider, p.id!, p.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/project/form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProjectProvider provider, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('\u5220\u9664\u9879\u76ee'),
        content: Text('\u786e\u5b9a\u5220\u9664\u201c$name\u201d\u5417\uff1f'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u53d6\u6d88')),
          TextButton(
            onPressed: () { provider.deleteProject(id); Navigator.pop(ctx); },
            child: const Text('\u5220\u9664', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
