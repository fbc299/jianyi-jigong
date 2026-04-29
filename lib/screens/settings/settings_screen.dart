import 'package:flutter/material.dart';
import '../../config/constants.dart';

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
            _buildTile(context, Icons.backup, '备份与恢复', '导出 JSON/CSV，WebDAV 同步',
                () => Navigator.pushNamed(context, '/backup')),
          ]),
          _buildSection(context, '项目管理', [
            _buildTile(context, Icons.folder, '项目列表', '管理工地项目',
                () => Navigator.pushNamed(context, '/project')),
            _buildTile(context, Icons.people, '工人管理', '管理工人信息',
                () => Navigator.pushNamed(context, '/worker')),
          ]),
          _buildSection(context, '统计报表', [
            _buildTile(context, Icons.bar_chart, '月度统计', '查看本月工时与工资',
                () => Navigator.pushNamed(context, '/stats')),
            _buildTile(context, Icons.calendar_month, '年度统计', '查看年度汇总',
                () => Navigator.pushNamed(context, '/stats/yearly')),
            _buildTile(context, Icons.table_chart, '工资明细表', '工资收支明细',
                () => Navigator.pushNamed(context, '/salary/detail')),
          ]),
          _buildSection(context, '关于', [
            _buildTile(context, Icons.info, '关于简约记工',
                '版本 ${AppConstants.appVersion} | 无广告 · 单机运行 · 数据安全', () {
              showAboutDialog(
                context: context,
                applicationName: '简约记工',
                applicationVersion: AppConstants.appVersion,
                applicationIcon: const Icon(Icons.construction, size: 48, color: Colors.blue),
                children: [
                  const Text('一款轻量级的工地记工应用\n'),
                  const Text('✨ 特性：\n'
                      '• 无广告，完全免费\n'
                      '• 单机运行，无需联网\n'
                      '• 数据安全，本地存储\n'
                      '• 支持批量记工\n'
                      '• 支持 CSV/JSON 导出\n'
                      '• 支持 WebDAV 备份到 NAS\n'),
                ],
              );
            }),
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
