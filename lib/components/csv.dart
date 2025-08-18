import 'package:flutter/material.dart';

class CsvPage extends StatefulWidget {
  const CsvPage({super.key});

  @override
  State<CsvPage> createState() => _CsvPageState();
}

class _CsvPageState extends State<CsvPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Center(child: Text("csv")),
          ],
        ),
      ),
    );
  }
}
