import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u8bbe\u7f6e')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection(context, '\u9879\u76ee\u7ba1\u7406', [
            _buildTile(context, Icons.folder, '\u9879\u76ee\u5217\u8868', '\u7ba1\u7406\u5de5\u5730\u9879\u76ee', () {
              Navigator.pushNamed(context, '/project/list');
            }),
            _buildTile(context, Icons.people, '\u5de5\u4eba\u7ba1\u7406', '\u7ba1\u7406\u5de5\u4eba\u4fe1\u606f', () {
              Navigator.pushNamed(context, '/worker/list');
            }),
          ]),
          _buildSection(context, '\u6570\u636e\u7ba1\u7406', [
            _buildTile(context, Icons.backup, '\u5907\u4efd\u6570\u636e', '\u5bfc\u51fa JSON/CSV', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u529f\u80fd\u5f00\u53d1\u4e2d...')));
            }),
            _buildTile(context, Icons.restore, '\u6062\u590d\u6570\u636e', '\u4ece\u5907\u4efd\u6587\u4ef6\u6062\u590d', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u529f\u80fd\u5f00\u53d1\u4e2d...')));
            }),
            _buildTile(context, Icons.cloud_upload, 'WebDAV \u540c\u6b65', '\u5907\u4efd\u5230 NAS', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u529f\u80fd\u5f00\u53d1\u4e2d...')));
            }),
          ]),
          _buildSection(context, '\u5173\u4e8e', [
            _buildTile(context, Icons.info, '\u5173\u4e8e\u7b80\u7ea6\u8bb0\u5de5', '\u7248\u672c 1.0.0', () {}),
            _buildTile(context, Icons.star, '\u7ed9\u4e2a\u597d\u8bc4', '\u5982\u679c\u89c9\u5f97\u597d\u7528', () {}),
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
