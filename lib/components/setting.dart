import 'package:flutter/material.dart';
import 'package:nantokanaru/components/csv.dart';
// import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/widgets/custom_app_bar.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "setting",
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
          // ListTile(
          //   title: const Text("データ全削除"),
          //   trailing: const Icon(Icons.delete_forever),
          //   onTap: () async {
          //     await DatabaseHelper.instance.clearTradeRecords("trade_records");
          //   },
          // ),
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
