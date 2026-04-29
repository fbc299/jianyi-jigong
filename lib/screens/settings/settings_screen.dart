import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection(context, '数据管理', [
            _buildTile(context, Icons.backup, '备份数据', '导出 JSON/CSV', () {}),
            _buildTile(context, Icons.restore, '恢复数据', '从备份文件恢复', () {}),
            _buildTile(context, Icons.cloud_upload, 'WebDAV 同步', '备份到 NAS', () {}),
          ]),
          _buildSection(context, '项目管理', [
            _buildTile(context, Icons.folder, '项目列表', '管理工地项目', () {}),
            _buildTile(context, Icons.people, '工人管理', '管理工人信息', () {}),
          ]),
          _buildSection(context, '关于', [
            _buildTile(context, Icons.info, '关于简约记工', '版本 1.0.0', () {}),
            _buildTile(context, Icons.star, '给个好评', '如果觉得好用', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          )),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
