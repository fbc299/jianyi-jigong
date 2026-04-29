import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/export_utils.dart';
import '../../database/database_helper.dart';
import 'package:path/path.dart' as p;

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isExporting = false;
  String _lastAction = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据备份')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Export section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📤 导出数据', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.code,
                    title: '导出 JSON',
                    subtitle: '完整数据备份，可用于恢复',
                    onTap: () => _exportJson(),
                  ),
                  _buildActionTile(
                    icon: Icons.table_chart,
                    title: '导出工时 CSV',
                    subtitle: '工时记录表格，可用 Excel 打开',
                    onTap: () => _exportWorkCsv(),
                  ),
                  _buildActionTile(
                    icon: Icons.table_chart,
                    title: '导出工资 CSV',
                    subtitle: '工资记录表格，可用 Excel 打开',
                    onTap: () => _exportSalaryCsv(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Import section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📥 导入/恢复', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.restore,
                    title: '从 JSON 恢复',
                    subtitle: '从之前导出的 JSON 文件恢复数据',
                    onTap: () => _restoreFromJson(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // WebDAV section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('☁️ WebDAV 同步', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.cloud_upload,
                    title: '备份到 NAS',
                    subtitle: '通过 WebDAV 上传到 NAS',
                    onTap: () => _webdavBackup(),
                  ),
                  _buildActionTile(
                    icon: Icons.cloud_download,
                    title: '从 NAS 恢复',
                    subtitle: '从 NAS 下载备份并恢复',
                    onTap: () => _webdavRestore(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status
          if (_lastAction.isNotEmpty)
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_lastAction)),
                  ],
                ),
              ),
            ),

          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _isExporting ? null : onTap,
    );
  }

  Future<void> _exportJson() async {
    setState(() => _isExporting = true);
    try {
      final file = await ExportUtils.exportToJson();
      setState(() {
        _lastAction = 'JSON 已导出: \${file.path}';
        _isExporting = false;
      });
      _showSnackBar('JSON 导出成功', Colors.green);
    } catch (e) {
      setState(() => _isExporting = false);
      _showSnackBar('导出失败: \$e', Colors.red);
    }
  }

  Future<void> _exportWorkCsv() async {
    setState(() => _isExporting = true);
    try {
      final file = await ExportUtils.exportWorkToCsv();
      setState(() {
        _lastAction = '工时 CSV 已导出: \${file.path}';
        _isExporting = false;
      });
      _showSnackBar('工时 CSV 导出成功', Colors.green);
    } catch (e) {
      setState(() => _isExporting = false);
      _showSnackBar('导出失败: \$e', Colors.red);
    }
  }

  Future<void> _exportSalaryCsv() async {
    setState(() => _isExporting = true);
    try {
      final file = await ExportUtils.exportSalaryToCsv();
      setState(() {
        _lastAction = '工资 CSV 已导出: \${file.path}';
        _isExporting = false;
      });
      _showSnackBar('工资 CSV 导出成功', Colors.green);
    } catch (e) {
      setState(() => _isExporting = false);
      _showSnackBar('导出失败: \$e', Colors.red);
    }
  }

  Future<void> _restoreFromJson() async {
    // Show info dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复数据'),
        content: const Text('恢复功能需要在文件管理器中找到之前导出的 JSON 文件，然后通过"打开方式"选择本应用导入。\n\n或者将 JSON 文件放到手机存储的 /Download/ 目录下，应用会自动检测。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }

  Future<void> _webdavBackup() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('WebDAV 备份'),
        content: const Text('请先在设置中配置 WebDAV 服务器地址、用户名和密码。\n\n支持的 NAS 系统：\n• 群晖 DSM\n• 威联通 QTS\n• fnOS 飞牛\n• 自建 WebDAV 服务'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }

  Future<void> _webdavRestore() async {
    _webdavBackup(); // Same dialog for now
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
