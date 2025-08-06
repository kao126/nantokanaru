import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TextFormPage extends StatefulWidget {
  const TextFormPage({super.key});

  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _choiceIndex = 0;
  DateTime _selectedDate = DateTime.now();

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250, // ボトムシートの高さを設定
          child: Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date, // 日付モードに設定
              initialDateTime: _selectedDate, // 初期日付
              minimumDate: DateTime(1950, 1, 1), // 最小日付（1950年1月1日）
              maximumDate: DateTime.now(), // 最大日付（今日の日付）
              onDateTimeChanged: (DateTime newDate) {
                // 日付変更時にテキストフィールドに反映
                setState(() {
                  _selectedDate = newDate;
                  _dateController.text =
                      "${newDate.year}年${newDate.month}月${newDate.day}日";
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _dayController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Form'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _dateController,
              readOnly: true, // タップでのみ日付選択可能
              decoration: const InputDecoration(
                labelText: "日付",
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              // フィールドがタップされた時に日付ピッカーを表示
              onTap: () => _showDatePicker(context),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dayController,
              decoration: const InputDecoration(
                hintText: '銘柄',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                hintText: '金額',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: 0.785398, // 45度
                        child: const Icon(Icons.push_pin,
                            size: 24, color: Color(0xffc3b491)),
                      ),
                      const Text("株式投資(信用)"),
                    ],
                  ),
                  labelStyle: const TextStyle(fontSize: 10),
                  selected: _choiceIndex == 0,
                  side: _choiceIndex == 0
                      ? const BorderSide(color: Colors.black87, width: 0.5)
                      : const BorderSide(color: Colors.transparent, width: 0.5),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    setState(() {
                      _choiceIndex = 0;
                    });
                  },
                ),
                ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: 0.785398, // 45度
                        child: const Icon(Icons.push_pin,
                            size: 24, color: Color(0xff676767)),
                      ),
                      const Text("株式投資(現物)"),
                    ],
                  ),
                  labelStyle: const TextStyle(fontSize: 10),
                  selected: _choiceIndex == 1,
                  side: _choiceIndex == 1
                      ? const BorderSide(color: Colors.black87, width: 0.5)
                      : const BorderSide(color: Colors.transparent, width: 0.5),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    setState(() {
                      _choiceIndex = 1;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
