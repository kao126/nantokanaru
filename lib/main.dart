import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:nantokanaru/components/card.dart';
import 'package:nantokanaru/components/calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null); // 必要なロケールを指定
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'カレンダー';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
                // ショップバッグアイコンが押されたときの処理
              },
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // EndDrawerを開く
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('About Us'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Log In'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: const CalendarPage(),
        // body: Builder(builder: (context) {
        //   final width = MediaQuery.of(context).size.width;

        //   // 画面の幅に応じて列数を決定
        //   int crossAxisCount;
        //   if (width < 768) {
        //     crossAxisCount = 1;
        //   } else {
        //     crossAxisCount = 3;
        //   }

        //   return GridView.count(
        //       crossAxisCount: crossAxisCount, // 2列に指定
        //       children: [
        //         ...destinations.map((destination) {
        //           return Center(
        //             child: TappableTravelDestinationItem(
        //               destination: destination,
        //             ),
        //           );
        //         }),
        //       ]);
        // })
      ),
    );
  }
}
