import 'package:flutter/material.dart';
import 'package:nantokanaru/components/csv.dart';
import 'package:nantokanaru/db/database_helper.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("setting"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("CSVデータ入力"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.of(context).push<ThemeMode>(
                MaterialPageRoute(
                  builder: (context) => const CsvPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("データ全削除"),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              await DatabaseHelper.instance.clearTradeRecords("trade_records");
            },
          ),
          SwitchListTile(
            title: const Text("通知を有効にする"),
            value: true,
            onChanged: (val) {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("言語"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
