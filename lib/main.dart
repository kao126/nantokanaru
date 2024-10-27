import 'package:flutter/material.dart';
import 'package:nantokanaru/components/card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Nantokanaru';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(title: const Text(title)),
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
        body: GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            shrinkWrap: true,
            crossAxisCount: 2,
            // Generate 100 widgets that display their index in the List.
            children: [
              ...destinations.map((destination) {
                return Center(
                  child: TravelDestinationItem(
                    destination: destination,
                  ),
                );
              }),
              ...destinations.map((destination) {
                return Center(
                  child: TappableTravelDestinationItem(
                    destination: destination,
                  ),
                );
              }),
            ]),
      ),
    );
  }
}
