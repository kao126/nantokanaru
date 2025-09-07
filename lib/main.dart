import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nantokanaru/components/text_form.dart';
import 'package:nantokanaru/components/graph.dart';
import 'package:nantokanaru/components/calendar.dart';
import 'package:nantokanaru/components/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null); // 必要なロケールを指定
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'NantoKanaru';

    return const MaterialApp(
      title: title,
      home: HomePage(),
      //日本語表記のためのローカライズ設定
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja'),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class NavigationItem {
  final String label;
  final Icon icon;
  final Widget page;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<NavigationItem> _items = [
    NavigationItem(
      label: "入力",
      icon: Icon(Icons.edit_document),
      page: TextFormPage(),
    ),
    NavigationItem(
      label: "グラフ",
      icon: Icon(Icons.auto_graph),
      page: GraphPage(),
    ),
    NavigationItem(
      label: "カレンダー",
      icon: Icon(Icons.calendar_month),
      page: CalendarPage(),
    ),
    NavigationItem(
      label: "設定",
      icon: Icon(Icons.settings),
      page: SettingPage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 選択中インデックスを更新
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _items[_selectedIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _items
            .map(
              (item) =>
                  BottomNavigationBarItem(icon: item.icon, label: item.label),
            )
            .toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
